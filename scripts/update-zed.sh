#!/usr/bin/env bash

# Script to update zed-editor package to the latest version.
# Usage: ./update-zed.sh [version]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/../pkgs/zed-editor.nix"
CHANNEL="${ZED_CHANNEL:-stable}"

get_latest_version() {
  local location
  location="$(
    curl -s -L -D - -o /dev/null \
      "https://cloud.zed.dev/releases/${CHANNEL}/latest/download?asset=zed&arch=x86_64&os=linux&source=update-zed.sh" \
      | sed -n 's/^location: //Ip' \
      | tr -d '\r' \
      | tail -n1
  )"

  if [[ -z "$location" ]]; then
    echo "Error: Could not resolve latest Zed release URL" >&2
    exit 1
  fi

  echo "$location" | sed -E 's|.*/v([^/]+)/.*|\1|'
}

to_sri() {
  local hash="$1"
  nix hash convert --hash-algo sha256 --to sri "$hash"
}

prefetch_hash() {
  local arch="$1"
  local version="$2"
  local url
  url="https://cloud.zed.dev/releases/${CHANNEL}/${version}/download?asset=zed&arch=${arch}&os=linux&source=update-zed.sh"
  nix-prefetch-url --name "zed-linux-${arch}.tar.gz" "$url"
}

if [ $# -eq 1 ]; then
  VERSION="$1"
  echo "Using provided version: $VERSION"
else
  echo "Fetching latest Zed version from channel: $CHANNEL"
  VERSION="$(get_latest_version)"
  echo "Latest version: $VERSION"
fi

echo "Calculating hashes..."
X86_HASH="$(to_sri "$(prefetch_hash x86_64 "$VERSION")")"
AARCH64_HASH="$(to_sri "$(prefetch_hash aarch64 "$VERSION")")"

echo "Updating package file..."
sed -i "s/version = \".*\";/version = \"$VERSION\";/" "$PACKAGE_FILE"
sed -i "s/channel = \".*\";/channel = \"$CHANNEL\";/" "$PACKAGE_FILE"
sed -i "s|x86Hash = \"sha256-[^\"]*\";|x86Hash = \"$X86_HASH\";|" "$PACKAGE_FILE"
sed -i "s|aarch64Hash = \"sha256-[^\"]*\";|aarch64Hash = \"$AARCH64_HASH\";|" "$PACKAGE_FILE"

echo "Package updated successfully!"
echo "Version: $VERSION"
echo "Channel: $CHANNEL"
echo "x86_64 hash: $X86_HASH"
echo "aarch64 hash: $AARCH64_HASH"
echo
echo "You can now rebuild with:"
echo "sudo nixos-rebuild switch --flake .#hydenix"
