#!/bin/bash
# ==============================================================================
# APT Repository Update Script (Multi-Architecture)
# ==============================================================================
# This script regenerates the Packages index file after adding new .deb files.
# Supports both amd64 and arm64 architectures.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
POOL_DIR="$REPO_ROOT/pool/main"
ARCHITECTURES="amd64 arm64"

echo "📦 Updating APT repository index..."
echo "   Pool: $POOL_DIR"
echo "   Architectures: $ARCHITECTURES"

# Ensure directories exist
mkdir -p "$POOL_DIR"

cd "$REPO_ROOT"

echo ""
echo "🔍 Scanning for .deb packages..."

# Generate Packages file for each architecture
for ARCH in $ARCHITECTURES; do
    DIST_DIR="$REPO_ROOT/dists/stable/main/binary-$ARCH"
    mkdir -p "$DIST_DIR"
    
    if ls pool/main/*.deb 1> /dev/null 2>&1; then
        # Filter packages by architecture
        dpkg-scanpackages --multiversion --arch "$ARCH" pool/main > "$DIST_DIR/Packages" 2>/dev/null || \
        dpkg-scanpackages --multiversion pool/main 2>/dev/null | grep -A 100 "Architecture: $ARCH\|Architecture: all" > "$DIST_DIR/Packages" || true
        
        # Fallback: scan all and filter
        if [ ! -s "$DIST_DIR/Packages" ]; then
            dpkg-scanpackages --multiversion pool/main 2>/dev/null > /tmp/all-packages.txt || true
            # Simple approach: just use all packages for now
            cp /tmp/all-packages.txt "$DIST_DIR/Packages"
        fi
        
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
        
        PACKAGE_COUNT=$(grep -c "^Package:" "$DIST_DIR/Packages" 2>/dev/null || echo "0")
        echo "   ✅ $ARCH: $PACKAGE_COUNT package(s)"
    else
        echo "" > "$DIST_DIR/Packages"
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
        echo "   ⚠️ $ARCH: No packages found"
    fi
done

# Generate Release file
echo ""
echo "📝 Generating Release file..."

cat > "$REPO_ROOT/dists/stable/Release" << EOF
Origin: KoukeNeko
Label: KoukeNeko APT Repository
Suite: stable
Codename: stable
Architectures: amd64 arm64
Components: main
Description: Personal APT repository by KoukeNeko
Date: $(date -Ru)
EOF

# Add checksums to Release file
cd "$REPO_ROOT/dists/stable"

{
    echo "MD5Sum:"
    find main -type f | while read file; do
        SIZE=$(wc -c < "$file")
        HASH=$(md5sum "$file" | cut -d' ' -f1)
        echo " $HASH $SIZE $file"
    done
    echo "SHA256:"
    find main -type f | while read file; do
        SIZE=$(wc -c < "$file")
        HASH=$(sha256sum "$file" | cut -d' ' -f1)
        echo " $HASH $SIZE $file"
    done
} >> Release

echo "   ✅ Release file generated"

# Sign Release file if GPG key is available
if [ -n "$GPG_PRIVATE_KEY" ]; then
    echo ""
    echo "🔐 Signing Release file..."
    echo "$GPG_PRIVATE_KEY" | gpg --batch --import 2>/dev/null || true
    gpg --batch --yes --armor --detach-sign -o Release.gpg Release
    gpg --batch --yes --armor --clearsign -o InRelease Release
    echo "   ✅ Release signed"
elif gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    echo ""
    echo "🔐 Signing Release file with local key..."
    gpg --batch --yes --armor --detach-sign -o Release.gpg Release
    gpg --batch --yes --armor --clearsign -o InRelease Release
    echo "   ✅ Release signed"
else
    echo ""
    echo "⚠️ No GPG key found, skipping signature"
fi

echo ""
echo "✅ Repository update complete!"
