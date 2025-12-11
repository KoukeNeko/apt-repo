#!/bin/bash
# ==============================================================================
# Package Repository Update Script (Multi-Suite APT + RPM)
# ==============================================================================
# Supports: stable, beta, dev suites
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SUITES="stable beta dev"
ARCHITECTURES="amd64 arm64"

echo "📦 Updating package repositories..."
echo "   Suites: $SUITES"

# ===========================================================================
# APT Repository - Process each suite
# ===========================================================================
for SUITE in $SUITES; do
    POOL_DIR="$REPO_ROOT/apt/pool/$SUITE"
    
    # Skip if pool doesn't exist
    if [ ! -d "$POOL_DIR" ]; then
        continue
    fi
    
    echo ""
    echo "=== APT Suite: $SUITE ==="
    
    cd "$REPO_ROOT/apt"
    
    for ARCH in $ARCHITECTURES; do
        DIST_DIR="$REPO_ROOT/apt/dists/$SUITE/main/binary-$ARCH"
        mkdir -p "$DIST_DIR"
        
        if find pool/$SUITE -name "*.deb" 2>/dev/null | head -1 | grep -q .; then
            dpkg-scanpackages --multiversion pool/$SUITE 2>/dev/null > "$DIST_DIR/Packages" || true
            gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
            echo "   ✅ $SUITE/$ARCH: $(grep -c "^Package:" "$DIST_DIR/Packages" 2>/dev/null || echo 0) packages"
        else
            echo "" > "$DIST_DIR/Packages"
            gzip -9c "$DIST_DIR/Packages" > "$DIST_DIR/Packages.gz"
        fi
    done

    # Generate Release file for this suite
    cat > "$REPO_ROOT/apt/dists/$SUITE/Release" << EOF
Origin: KoukeNeko
Label: KoukeNeko Package Repository
Suite: $SUITE
Codename: $SUITE
Architectures: amd64 arm64
Components: main
Date: $(date -Ru)
EOF

    cd "$REPO_ROOT/apt/dists/$SUITE"
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
        echo "   ✅ $SUITE Release signed"
    fi
done

# ===========================================================================
# RPM Repository
# ===========================================================================
echo ""
echo "=== RPM Repository ==="

mkdir -p "$REPO_ROOT/rpm/packages"
cd "$REPO_ROOT/rpm"

if ls packages/*.rpm 1> /dev/null 2>&1; then
    createrepo_c --update . 2>/dev/null || createrepo --update . 2>/dev/null || true
    echo "   ✅ RPM: $(ls packages/*.rpm 2>/dev/null | wc -l) packages"
else
    createrepo_c . 2>/dev/null || createrepo . 2>/dev/null || true
fi

echo ""
echo "✅ Repository update complete!"
