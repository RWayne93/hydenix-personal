#!/usr/bin/env bash

# Script to update Warp terminal package to the latest version
# Usage: ./update-warp.sh [version]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/../pkgs/warp-terminal.nix"

# Function to get the latest version by following redirect
get_latest_version() {
    # Follow the redirect and extract version from the location header
    local version
    version=$(curl -s -L -D - -o /dev/null 'https://app.warp.dev/download?package=pacman' | grep -i '^location:' | tr -d '\r' | sed -E 's|.*stable/v([^/]+)/.*|\1|')
    
    if [[ -z "$version" ]]; then
        echo "Error: Could not extract version from redirect URL" >&2
        exit 1
    fi
    
    echo "$version"
}

# Function to calculate hash for a URL
get_hash() {
    local url="$1"
    nix-prefetch-url "$url"
}

# Function to convert hash to SRI format
to_sri() {
    local hash="$1"
    nix hash to-sri --type sha256 "$hash"
}

# Get version from argument or fetch latest
if [ $# -eq 1 ]; then
    VERSION="$1"
    echo "Using provided version: $VERSION"
else
    echo "Fetching latest version..."
    VERSION=$(get_latest_version)
    echo "Latest version: $VERSION"
fi

# Detect architecture and only fetch that hash
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    aarch64|arm64)
        ARCH="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

URL="https://releases.warp.dev/stable/v${VERSION}/warp-terminal-v${VERSION}-1-${ARCH}.pkg.tar.zst"

echo "Calculating hash for $ARCH..."
HASH=$(get_hash "$URL")
SRI=$(to_sri "$HASH")

echo "Updating package file..."

# Update the package file
sed -i "s/version = \".*\";/version = \"$VERSION\";/" "$PACKAGE_FILE"
if [[ "$ARCH" == "x86_64" ]]; then
    sed -i "s|\"sha256-[^\"]*\" else|\"$SRI\" else|" "$PACKAGE_FILE"
else
    sed -i "s|else \"sha256-[^\"]*\";|else \"$SRI\";|" "$PACKAGE_FILE"
fi

echo "Package updated successfully!"
echo "Version: $VERSION"
echo "$ARCH hash: $SRI"
echo ""
echo "You can now rebuild with:"
echo "sudo nixos-rebuild switch --flake ."

