#!/bin/bash
# ==============================================================================
# Package Repository Update Script (APT + RPM)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📦 Updating package repositories..."

# ===========================================================================
# APT Repository
# ===========================================================================
APT_POOL="$REPO_ROOT/apt/pool/main"
mkdir -p "$APT_POOL"

cd "$REPO_ROOT/apt"

for ARCH in amd64 arm64; do
    DIST_DIR="$REPO_ROOT/apt/dists/stable/main/binary-$ARCH"
    mkdir -p "$DIST_DIR"
    
    if ls pool/main/*.deb 1> /dev/null 2>&1; then
        dpkg-scanpackages --multiversion pool/main 2>/dev/null > "$DIST_DIR/Packages" || true
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
        echo "   ✅ APT $ARCH: $(grep -c "^Package:" "$DIST_DIR/Packages" 2>/dev/null || echo 0) packages"
    else
        echo "" > "$DIST_DIR/Packages"
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
    fi
done

cat > "$REPO_ROOT/apt/dists/stable/Release" << EOF
Origin: KoukeNeko
Label: KoukeNeko Package Repository
Suite: stable
Codename: stable
Architectures: amd64 arm64
Components: main
Date: $(date -Ru)
EOF

cd "$REPO_ROOT/apt/dists/stable"
{
    echo "MD5Sum:"
    find main -type f | while read file; do
        echo " $(md5sum "$file" | cut -d' ' -f1) $(wc -c < "$file") $file"
    done
    echo "SHA256:"
    find main -type f | while read file; do
        echo " $(sha256sum "$file" | cut -d' ' -f1) $(wc -c < "$file") $file"
    done
} >> Release

# ===========================================================================
# RPM Repository
# ===========================================================================
mkdir -p "$REPO_ROOT/rpm/packages"
cd "$REPO_ROOT/rpm"

if ls packages/*.rpm 1> /dev/null 2>&1; then
    createrepo_c --update . 2>/dev/null || createrepo --update . 2>/dev/null || true
    echo "   ✅ RPM: $(ls packages/*.rpm 2>/dev/null | wc -l) packages"
else
    createrepo_c . 2>/dev/null || createrepo . 2>/dev/null || true
fi

# ===========================================================================
# Sign APT Release
# ===========================================================================
cd "$REPO_ROOT/apt/dists/stable"

if [ -n "$GPG_PRIVATE_KEY" ]; then
    echo "$GPG_PRIVATE_KEY" | gpg --batch --import 2>/dev/null || true
    gpg --batch --yes --armor --detach-sign -o Release.gpg Release
    gpg --batch --yes --armor --clearsign -o InRelease Release
    echo "   ✅ APT Release signed"
elif gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    gpg --batch --yes --armor --detach-sign -o Release.gpg Release
    gpg --batch --yes --armor --clearsign -o InRelease Release
fi

echo "✅ Repository update complete!"
