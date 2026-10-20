#!/usr/bin/env sh
set -eu

REPO="ironbook-labs/ironbook"

# Embedded GPG Public Key
PUBKEY=$(cat << 'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEatO0gxYJKwYBBAHaRw8BAQdA1z+O3uZCiv1OzUMVN0tNt2MRprFVbOqCgff5
l3BcpNC0NUlyb25ib29rIChJcm9uYm9vayBvcmcga2V5IHRvIHNpZ24gaXJvbmJv
b2sgcmVsZWFzZXMpiJAEExYKADgWIQSvLtlnKsTVbtYPFCTUE41y+Qe3qAUCatO0
gwIbAwULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRDUE41y+Qe3qOZRAP9pX1QS
3XLJlTePjuld2auBWykSGaMQqczW39A6yFPJbAD6A04P/uRptK/qx2EzkRghZ6Q7
iKOBex3nPtEI2tANmwa4OARq07SDEgorBgEEAZdVAQUBAQdAQf5H1hwGk53cJ3Fh
KSd7IaICnDLESO85UVVfZ3ISrmwDAQgHiHgEGBYKACAWIQSvLtlnKsTVbtYPFCTU
E41y+Qe3qAUCatO0gwIbDAAKCRDUE41y+Qe3qHDXAQCUH+KJYhbZZAOdB0AIh+G7
FIY8CL+cHJJ021pIKah5awEA/g1b7J7VVOaX59AElX75Dx2VEyKbeoigtGURUn7+
3QA=
=Gufy
-----END PGP PUBLIC KEY BLOCK-----
EOF
)

# Prerequisites check with user-friendly installation advice
MISSING_CMDS=""
for cmd in curl jq gpg unzip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING_CMDS="${MISSING_CMDS} $cmd"
  fi
done

if [ -n "$MISSING_CMDS" ]; then
  echo "Error: The following required command(s) are missing:$MISSING_CMDS" >&2
  echo "" >&2
  echo "Iron Book requires these tools to download, verify, and install the application." >&2
  echo "Please install them using your system's package manager and re-run the installer:" >&2
  echo "  - Debian / Ubuntu: sudo apt update && sudo apt install curl jq gnupg unzip" >&2
  echo "  - Fedora / RHEL:   sudo dnf install curl jq gnupg unzip" >&2
  echo "  - Arch Linux:    sudo pacman -S curl jq gnupg unzip" >&2
  echo "  - Alpine Linux:  sudo apk add curl jq gnupg unzip" >&2
  exit 1
fi

# Platform check: only the Linux x64 build is currently released. Refuse
# early on anything else, before prompting or touching ~/.local.
if [ "$(uname -s)" != "Linux" ]; then
  echo "Error: Unsupported operating system: $(uname -s). This installer supports Linux only." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|amd64)
    ;;
  *)
    echo "Error: Unsupported CPU architecture: $(uname -m). Only the x64 build is released." >&2
    exit 1
    ;;
esac

# 1. Prompt release channel
if [ -t 0 ]; then
  # Standard interactive execution
  printf "Select release type ([s]table / [p]re-release): "
  read -r RELEASE_CHOICE
elif [ -c /dev/tty ]; then
  # Piped execution (curl ... | sh): Redirect FD 3 from /dev/tty
  exec 3< /dev/tty
  printf "Select release type ([s]table / [p]re-release): " >&2
  read -r RELEASE_CHOICE <&3
  exec 3<&-
else
  echo "Error: Terminal is non-interactive and no TTY is available." >&2
  exit 1
fi

case "$RELEASE_CHOICE" in
  [pP]*)
    API_URL="https://api.github.com/repos/${REPO}/releases"
    IS_LIST=true
    ;;
  *)
    API_URL="https://api.github.com/repos/${REPO}/releases/latest"
    IS_LIST=false
    ;;
esac

echo "Fetching release metadata..."
API_RESPONSE=$(curl -fsSL "$API_URL") || {
  echo "Error: Failed to download release metadata from ${API_URL}." >&2
  exit 1
}

# Validate JSON response and handle API error conditions gracefully
if ! echo "$API_RESPONSE" | jq -e . >/dev/null 2>&1; then
  echo "Error: Received invalid JSON response from GitHub API (possible captive portal or network proxy)." >&2
  exit 1
fi

API_MESSAGE=$(echo "$API_RESPONSE" | jq -r '.message // empty')
if [ -n "$API_MESSAGE" ] && [ "$API_MESSAGE" != "null" ]; then
  echo "Error from GitHub API: ${API_MESSAGE}" >&2
  if [ "$IS_LIST" = false ]; then
    echo "Hint: If no stable release exists yet, try running the installer again and select the [p]re-release channel." >&2
  else
    echo "Hint: If you are hitting API rate limits, please try again later." >&2
  fi
  exit 1
fi

if [ "$IS_LIST" = true ]; then
  ASSETS_JSON=$(echo "$API_RESPONSE" | jq -r '.[0].assets // empty')
else
  ASSETS_JSON=$(echo "$API_RESPONSE" | jq -r '.assets // empty')
fi

if [ -z "$ASSETS_JSON" ] || [ "$ASSETS_JSON" = "null" ]; then
  echo "Error: Could not retrieve release assets from GitHub API." >&2
  if [ "$IS_LIST" = false ]; then
    echo "Hint: If no stable release exists yet, try selecting the [p]re-release channel." >&2
  fi
  exit 1
fi

# Only install the Linux Desktop release.
ZIP_NAME=$(echo "$ASSETS_JSON" | jq -r '
  .[]
  | select(
      .name
      | test("^ironbook-desktop-v[0-9]+\\.[0-9]+\\.[0-9]+(?:-[0-9A-Za-z.-]+)?-linux-x64\\.zip$")
    )
  | .name
' | head -n 1)

if [ -z "$ZIP_NAME" ] || [ "$ZIP_NAME" = "null" ]; then
  echo "Error: Linux Desktop release archive was not found." >&2
  exit 1
fi

ZIP_URL=$(echo "$ASSETS_JSON" | jq -r \
  --arg name "$ZIP_NAME" \
  '.[] | select(.name == $name) | .browser_download_url' \
  | head -n 1)

ASC_NAME="${ZIP_NAME}.asc"

ASC_URL=$(echo "$ASSETS_JSON" | jq -r \
  --arg name "$ASC_NAME" \
  '.[] | select(.name == $name) | .browser_download_url' \
  | head -n 1)

if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" = "null" ]; then
  echo "Error: Linux Desktop release archive URL was not found." >&2
  exit 1
fi

if [ -z "$ASC_URL" ] || [ "$ASC_URL" = "null" ]; then
  echo "Error: Release signature (.asc) was not found for ${ZIP_NAME}." >&2
  exit 1
fi

echo "Selected release: ${ZIP_NAME}"

# 2. Setup temporary workspace
TMP_DIR=$(mktemp -d)
GNUPGHOME=$(mktemp -d)
export GNUPGHOME
chmod 700 "$GNUPGHOME"

cleanup() {
  rm -rf "$TMP_DIR" "$GNUPGHOME"
}
trap cleanup EXIT INT TERM

ZIP_FILE="${TMP_DIR}/${ZIP_NAME}"
ASC_FILE="${TMP_DIR}/${ASC_NAME}"
KEY_FILE="${TMP_DIR}/pubkey.asc"

# 3. Download release files
echo "Downloading archive..."
curl -fsSL -o "$ZIP_FILE" "$ZIP_URL" || {
  echo "Error: Failed to download release archive from ${ZIP_URL}." >&2
  exit 1
}

echo "Downloading signature..."
curl -fsSL -o "$ASC_FILE" "$ASC_URL" || {
  echo "Error: Failed to download release signature from ${ASC_URL}." >&2
  exit 1
}

# 4. GPG Verification
echo "$PUBKEY" > "$KEY_FILE"
gpg --quiet --batch --import "$KEY_FILE"

echo "Verifying GPG signature..."
if gpg --quiet --batch --verify "$ASC_FILE" "$ZIP_FILE"; then
  echo "Signature verification successful!"
else
  echo "Error: GPG signature verification failed! Aborting." >&2
  exit 1
fi

# 5. Extraction & Path Setup (with atomic backup rotation)
TARGET_SHARE="${HOME}/.local/share/ironbook"
TARGET_BIN="${HOME}/.local/bin"
TARGET_APPS="${HOME}/.local/share/applications"

mkdir -p "$TARGET_BIN" "$TARGET_APPS" "${HOME}/.local/share"

echo "Extracting application..."
mkdir -p "$TMP_DIR/extracted"
unzip -q "$ZIP_FILE" -d "$TMP_DIR/extracted"

# Handle top-level directory flattening inside zip if necessary.
EXTRACTED_CONTENT=$(ls -A "$TMP_DIR/extracted")

if [ "$(echo "$EXTRACTED_CONTENT" | wc -l)" -eq 1 ] \
  && [ -d "$TMP_DIR/extracted/$EXTRACTED_CONTENT" ]; then
  SRC_DIR="$TMP_DIR/extracted/$EXTRACTED_CONTENT"
else
  SRC_DIR="$TMP_DIR/extracted"
fi

NEW_SHARE="${TMP_DIR}/new_ironbook"
mkdir -p "$NEW_SHARE"
cp -a "${SRC_DIR}/." "$NEW_SHARE/"
rm -rf "$TMP_DIR/extracted"

# Ensure main binary is executable.
chmod +x "${NEW_SHARE}/ironbook"

# 6. Generate embedded Uninstaller inside NEW_SHARE
cat << 'EOF' > "${NEW_SHARE}/uninstall.sh"
#!/usr/bin/env sh
set -eu

TARGET_SHARE="${HOME}/.local/share/ironbook"
TARGET_BIN="${HOME}/.local/bin/ironbook"
TARGET_DESKTOP="${HOME}/.local/share/applications/ironbook.desktop"

CONFIG_DIR="${HOME}/.config/ironbook"
DATA_DIR="${HOME}/.local/share/ironbook_data"

echo "Uninstalling Iron Book..."

printf "\nDo you also want to remove persistent app configuration and user databases? [y/N]: "
read -r REMOVE_DATA || REMOVE_DATA=n

case "$REMOVE_DATA" in
  [yY]*)
    [ -d "$CONFIG_DIR" ] \
      && rm -rf "$CONFIG_DIR" \
      && echo "Removed ${CONFIG_DIR}"

    [ -d "$DATA_DIR" ] \
      && rm -rf "$DATA_DIR" \
      && echo "Removed ${DATA_DIR}"

    echo "App data purged."
    ;;
  *)
    echo "App configuration and user data retained."
    ;;
esac

if [ -d "$TARGET_SHARE" ]; then
  rm -rf "$TARGET_SHARE"
  echo "Removed app binaries: ${TARGET_SHARE}"
fi

if [ -f "$TARGET_DESKTOP" ]; then
  rm -f "$TARGET_DESKTOP"
  echo "Removed desktop entry: ${TARGET_DESKTOP}"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database \
    "${HOME}/.local/share/applications" \
    2>/dev/null || true
fi

if [ -f "$TARGET_BIN" ]; then
  rm -f "$TARGET_BIN"
  echo "Removed wrapper script: ${TARGET_BIN}"
fi

echo "Iron Book has been successfully uninstalled."
EOF

chmod +x "${NEW_SHARE}/uninstall.sh"

# Perform atomic switch using backup rotation
BACKUP_SHARE="${TARGET_SHARE}.bak"
rm -rf "$BACKUP_SHARE"

if [ -d "$TARGET_SHARE" ]; then
  mv "$TARGET_SHARE" "$BACKUP_SHARE"
fi

mv "$NEW_SHARE" "$TARGET_SHARE"
rm -rf "$BACKUP_SHARE"

# 7. Wrapper script with --uninstall check
echo "Creating launcher wrapper in ${TARGET_BIN}/ironbook..."

cat << 'EOF' > "${TARGET_BIN}/ironbook"
#!/usr/bin/env sh

if [ "${1:-}" = "--uninstall" ]; then
  exec "${HOME}/.local/share/ironbook/uninstall.sh"
fi

exec "${HOME}/.local/share/ironbook/ironbook" "$@"
EOF

chmod +x "${TARGET_BIN}/ironbook"

# 8. Desktop Entry generation
echo "Creating desktop shortcut..."

cat << EOF > "${TARGET_APPS}/ironbook.desktop"
[Desktop Entry]
Type=Application
Name=IronBook
Comment=The Financial Ledger you need
Exec=${TARGET_BIN}/ironbook
Path=${TARGET_SHARE}
Icon=${TARGET_SHARE}/icon.png
Terminal=false
Categories=Utility;
EOF

echo "Installation complete!"
