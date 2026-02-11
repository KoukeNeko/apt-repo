#!/bin/bash
# ==============================================================================
# KoukeNeko APT Repository - Quick Install Script
# ==============================================================================
# Usage: curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash
# ==============================================================================

set -e

REPO_URL="https://koukeneko.github.io/pkg-repo/apt"
KEY_URL="https://koukeneko.github.io/pkg-repo/KEY.gpg"
KEYRING_PATH="/usr/share/keyrings/koukeneko.gpg"
LIST_PATH="/etc/apt/sources.list.d/koukeneko.list"

ensure_curl_installed() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "⚠️ curl is not installed. Installing..."
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get install -y -qq curl >/dev/null 2>&1
    fi
}

ensure_gpg_installed() {
    if ! command -v gpg >/dev/null 2>&1; then
        echo "⚠️ gpg is not installed. Installing..."
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get install -y -qq gnupg >/dev/null 2>&1
    fi
}

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   📦  KoukeNeko APT Repository Installer                         ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run as root (use sudo)"
    exit 1
fi

ensure_curl_installed
ensure_gpg_installed

echo "🔑 Installing GPG key..."
curl -fsSL "${KEY_URL}" | gpg --dearmor -o "${KEYRING_PATH}"
chmod 644 "${KEYRING_PATH}"

ARCH=$(dpkg --print-architecture)
echo "📋 Architecture: $ARCH"

echo "📋 Adding repository..."
echo "deb [arch=$ARCH signed-by=${KEYRING_PATH}] ${REPO_URL} stable main" > "${LIST_PATH}"

echo "🔄 Updating package list..."
apt-get update -o Dir::Etc::sourcelist="${LIST_PATH}" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" > /dev/null 2>&1 || apt-get update > /dev/null 2>&1

echo ""
echo "✅ Done! Available packages:"
echo ""
echo "   sudo apt install hashi        # stable"
echo "   sudo apt install hashi-beta   # beta"
echo "   sudo apt install hashi-dev    # dev"
echo ""
