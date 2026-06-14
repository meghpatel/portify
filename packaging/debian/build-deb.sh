#!/usr/bin/env bash
# Build a .deb package for portify.
#   Usage: bash packaging/debian/build-deb.sh [VERSION]
# Output: dist/portify_<version>_all.deb
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION="${1:-$(cat "$ROOT/VERSION")}"
PKG="portify"
STAGE="$(mktemp -d)"
OUT="$ROOT/dist"
DEB="$OUT/${PKG}_${VERSION}_all.deb"

mkdir -p "$OUT"

# --- lay out the package filesystem ---
install -d "$STAGE/DEBIAN"
install -d "$STAGE/usr/bin"
install -d "$STAGE/usr/share/doc/$PKG"

# control file (substitute version)
sed "s/__VERSION__/${VERSION}/" "$ROOT/packaging/debian/control.template" \
  > "$STAGE/DEBIAN/control"

# the program
install -m 0755 "$ROOT/portify" "$STAGE/usr/bin/portify"

# docs / license
install -m 0644 "$ROOT/LICENSE" "$STAGE/usr/share/doc/$PKG/copyright" 2>/dev/null || true
[[ -f "$ROOT/README.md" ]] && install -m 0644 "$ROOT/README.md" "$STAGE/usr/share/doc/$PKG/README.md"

# --- build ---
# --root-owner-group makes files owned by root:root without needing fakeroot
dpkg-deb --build --root-owner-group "$STAGE" "$DEB" >/dev/null

rm -rf "$STAGE"
echo "✓ Built: $DEB"
echo ""
dpkg-deb --info "$DEB" | sed 's/^/    /'
echo ""
echo "Install locally with:  sudo apt install $DEB"
echo "(or:                    sudo dpkg -i $DEB)"
