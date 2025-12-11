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
cd "$REPO_ROOT/apt"

for ARCH in amd64 arm64; do
    DIST_DIR="$REPO_ROOT/apt/dists/stable/main/binary-$ARCH"
    mkdir -p "$DIST_DIR"
    
    if find pool/stable -name "*.deb" 2>/dev/null | head -1 | grep -q .; then
        dpkg-scanpackages --multiversion pool/stable 2>/dev/null > "$DIST_DIR/Packages" || true
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
        echo "   ✅ APT $ARCH: $(grep -c "^Package:" "$DIST_DIR/Packages" 2>/dev/null || echo 0) packages"
    else
        echo "" > "$DIST_DIR/Packages"
        gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
    fi
done

# Generate Release file
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

# Sign Release file
if [ -n "$GPG_PRIVATE_KEY" ] || gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    gpg --batch --yes --armor --detach-sign -o Release.gpg Release 2>/dev/null || true
    gpg --batch --yes --armor --clearsign -o InRelease Release 2>/dev/null || true
    echo "   ✅ APT Release signed"
fi

# ===========================================================================
# RPM Repository
# ===========================================================================
echo ""
mkdir -p "$REPO_ROOT/rpm/packages"
cd "$REPO_ROOT/rpm"

if find packages -name "*.rpm" 2>/dev/null | head -1 | grep -q .; then
    createrepo_c --update . 2>/dev/null || createrepo --update . 2>/dev/null || true
    echo "   ✅ RPM: $(find packages -name "*.rpm" 2>/dev/null | wc -l) packages"
else
    createrepo_c . 2>/dev/null || createrepo . 2>/dev/null || true
fi

echo ""
echo "✅ Repository update complete!"
