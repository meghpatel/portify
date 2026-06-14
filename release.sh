#!/usr/bin/env bash
# Cut a new portify release.
#   Usage: bash release.sh <new-version>     e.g. bash release.sh 1.0.1
#
# What it does:
#   1. updates VERSION + the version strings in portify and the formula
#   2. commits, tags v<version>, and pushes
#   3. builds the .deb into dist/
#   4. downloads the GitHub source tarball and prints its sha256
#      (paste that into packaging/homebrew/portify.rb in your tap repo)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="${1:-}"
[[ -n "$VERSION" ]] || { echo "Usage: bash release.sh <version>  (e.g. 1.0.1)" >&2; exit 1; }
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Version must look like X.Y.Z" >&2; exit 1; }

REPO_SLUG="$(git config --get remote.origin.url | sed -E 's#.*github.com[:/](.+)\.git#\1#')"
[[ -n "$REPO_SLUG" ]] || { echo "Could not detect GitHub repo from git remote." >&2; exit 1; }

echo "→ Bumping version to $VERSION ..."
echo "$VERSION" > VERSION
sed -i.bak -E "s/^PORTIFY_VERSION=\".*\"/PORTIFY_VERSION=\"$VERSION\"/" portify && rm -f portify.bak
sed -i.bak -E "s#archive/refs/tags/v[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz#archive/refs/tags/v$VERSION.tar.gz#" \
  packaging/homebrew/portify.rb && rm -f packaging/homebrew/portify.rb.bak
sed -i.bak -E "s/^  version \".*\"/  version \"$VERSION\"/" packaging/homebrew/portify.rb && rm -f packaging/homebrew/portify.rb.bak

echo "→ Linting ..."
bash -n portify && echo "  ✓ syntax OK"

echo "→ Committing & tagging ..."
git add VERSION portify packaging/homebrew/portify.rb
git commit -m "Release v$VERSION" || echo "  (nothing to commit)"
git tag -a "v$VERSION" -m "portify v$VERSION"
git push origin HEAD
git push origin "v$VERSION"

echo "→ Building .deb ..."
bash packaging/debian/build-deb.sh "$VERSION"

echo "→ Fetching GitHub tarball to compute sha256 ..."
TARBALL_URL="https://github.com/$REPO_SLUG/archive/refs/tags/v$VERSION.tar.gz"
TMP="$(mktemp)"
# Give GitHub a moment to publish the tag archive
sleep 3
curl -fsSL "$TARBALL_URL" -o "$TMP"
SHA="$(shasum -a 256 "$TMP" | awk '{print $1}')"
rm -f "$TMP"

# Patch the formula's sha256 automatically
sed -i.bak -E "s/sha256 \".*\"/sha256 \"$SHA\"/" packaging/homebrew/portify.rb && rm -f packaging/homebrew/portify.rb.bak

cat <<EOF

────────────────────────────────────────────────────────────
✓ Release v$VERSION pushed and built.

Homebrew sha256 (already written into packaging/homebrew/portify.rb):
  $SHA

Next:
  1. Create the GitHub Release for tag v$VERSION and attach:
       dist/portify_${VERSION}_all.deb
  2. Copy packaging/homebrew/portify.rb into your TAP repo
     (homebrew-tap/Formula/portify.rb), commit & push.
  3. (Optional) Rebuild the apt repo:  bash packaging/apt-repo/build-apt-repo.sh
────────────────────────────────────────────────────────────
EOF
