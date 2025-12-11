#!/bin/bash
# ==============================================================================
# KoukeNeko RPM Repository - Quick Install Script
# ==============================================================================
# Usage: curl -fsSL https://koukeneko.github.io/pkg-repo/rpm/install.sh | sudo bash
# ==============================================================================

set -e

REPO_URL="https://koukeneko.github.io/pkg-repo/rpm"
KEY_URL="https://koukeneko.github.io/pkg-repo/KEY.gpg"

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   📦  KoukeNeko RPM Repository Installer                         ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run as root (use sudo)"
    exit 1
fi

if command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
elif command -v yum &> /dev/null; then
    PKG_MGR="yum"
else
    echo "❌ Error: Neither dnf nor yum found"
    exit 1
fi

echo "🔑 Importing GPG key..."
rpm --import "${KEY_URL}"

echo "📋 Adding repository..."
cat > /etc/yum.repos.d/koukeneko.repo << EOF
[koukeneko]
name=KoukeNeko Package Repository
baseurl=${REPO_URL}
enabled=1
gpgcheck=1
gpgkey=${KEY_URL}
EOF

echo "🔄 Updating package cache..."
$PKG_MGR makecache -q 2>/dev/null || true

echo ""
echo "✅ Done! Available packages:"
echo ""
echo "   sudo $PKG_MGR install hashi        # stable"
echo "   sudo $PKG_MGR install hashi-beta   # beta"
echo "   sudo $PKG_MGR install hashi-dev    # dev"
echo ""
