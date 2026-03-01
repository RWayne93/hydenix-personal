#!/usr/bin/env bash
set -euo pipefail

MODULE_PATH="/run/current-system/sw/lib/opensc-pkcs11.so"
GNUPG_HOME="${GNUPGHOME:-$HOME/.gnupg}"
SCDAEMON_CONF="$GNUPG_HOME/scdaemon.conf"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_cmd gpgsm
require_cmd gpgconf
require_cmd gpg
require_cmd opensc-tool
require_cmd pkcs11-tool

if [[ ! -f "$MODULE_PATH" ]]; then
  echo "OpenSC PKCS#11 module not found at $MODULE_PATH" >&2
  exit 1
fi

mkdir -p "$GNUPG_HOME"
chmod 700 "$GNUPG_HOME"

cat > "$SCDAEMON_CONF" <<'EOF'
disable-ccid
pcsc-shared
EOF

echo "Wrote scdaemon config to $SCDAEMON_CONF"

# Reset gpg-agent/keyboxd to pick up scdaemon.conf
gpgconf --kill gpg-agent || true
gpgconf --kill keyboxd || true

# Remove stale locks if present
rm -f "$GNUPG_HOME"/public-keys.d/.#lk* \
      "$GNUPG_HOME"/public-keys.d/*.lock \
      "$GNUPG_HOME"/pubring.db.lock \
      "$GNUPG_HOME"/.#lk* 2>/dev/null || true

mkdir -p "$GNUPG_HOME/public-keys.d"
chmod 700 "$GNUPG_HOME/public-keys.d"

echo "Checking smartcard reader..."
opensc-tool --list-readers || true
echo "Checking card status..."
gpg --card-status || true

echo "Scanning certificates on card..."
PKCS11_LIST="$(pkcs11-tool --module "$MODULE_PATH" -O)"
echo "$PKCS11_LIST"

CERT_ID="$(printf '%s\n' "$PKCS11_LIST" | awk '
  /Certificate Object/ {cert=1; label=""}
  cert && /label:/{label=$0}
  cert && /ID:/{id=$2}
  cert && /label:/ && /Digital Signature/ {want=1}
  cert && /ID:/ && want {print id; exit}
  cert && /Certificate Object/ {cert=1}
')"

if [[ -z "${CERT_ID:-}" ]]; then
  echo "Could not auto-detect a Digital Signature cert." >&2
  echo "Available cert IDs (use one of these):" >&2
  printf '%s\n' "$PKCS11_LIST" | awk '/Certificate Object/{c=1} c && /ID:/{print $2}'
  read -r -p "Enter certificate ID to use (e.g. 02): " CERT_ID
fi

CERT_PEM="$PWD/piv-signing-cert.pem"
echo "Exporting public certificate ID $CERT_ID to $CERT_PEM"
pkcs11-tool --module "$MODULE_PATH" \
  --read-object --type cert --id "$CERT_ID" --output-file "$CERT_PEM"

echo "Importing cert into gpgsm key database..."
gpgsm --import "$CERT_PEM"

echo "Current gpgsm keys:"
gpgsm --list-keys --with-fingerprint

echo
echo "If signing fails with 'Missing issuer certificate',"
echo "import the issuer/root CA certs and mark trust."
echo "Example:"
echo "  gpgsm --import /path/to/DoD_Root_CA_3.pem"
echo "  printf 'FPR S\\n' >> $GNUPG_HOME/trustlist.txt"
echo
echo "Git signing is optional. You can configure it per repo or globally."
read -r -p "Configure git signing globally now? [y/N] " CONFIG_GIT
if [[ "${CONFIG_GIT,,}" == "y" ]]; then
  require_cmd git
  read -r -p "Enter signing cert SHA1 fingerprint (no colons): " SIGN_FPR
  git config --global gpg.format x509
  git config --global gpg.x509.program gpgsm
  git config --global user.signingkey "$SIGN_FPR"
  git config --global commit.gpgsign true
  echo "Global git signing configured."
else
  echo "Skipping git config. To set it later (replace <FPR>):"
  echo "  git config --global gpg.format x509"
  echo "  git config --global gpg.x509.program gpgsm"
  echo "  git config --global user.signingkey <FPR>"
  echo "  git config --global commit.gpgsign true"
fi

