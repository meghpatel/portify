#!/usr/bin/env bash
# portify installer
#   curl -fsSL https://raw.githubusercontent.com/meghpatel/portify/main/install.sh | bash
#
# Installs the `portify` script to a bin directory on your PATH.
set -euo pipefail

REPO="meghpatel/portify"           
RAW="https://raw.githubusercontent.com/${REPO}/main/portify"

# Pick an install dir we can actually write to, preferring system-wide.
choose_bindir() {
  if [[ -w "/usr/local/bin" ]]; then
    echo "/usr/local/bin"
  elif command -v sudo &>/dev/null && [[ -d "/usr/local/bin" ]]; then
    echo "/usr/local/bin"   # will use sudo below
  else
    echo "$HOME/.local/bin"
  fi
}

main() {
  local bindir use_sudo=""
  bindir="$(choose_bindir)"
  [[ "$bindir" == "/usr/local/bin" && ! -w "$bindir" ]] && use_sudo="sudo"

  mkdir -p "$bindir"
  echo "Installing portify to ${bindir}/portify ..."

  local tmp; tmp="$(mktemp)"
  if command -v curl &>/dev/null; then
    curl -fsSL "$RAW" -o "$tmp"
  elif command -v wget &>/dev/null; then
    wget -qO "$tmp" "$RAW"
  else
    echo "Error: need curl or wget." >&2; exit 1
  fi

  $use_sudo install -m 0755 "$tmp" "${bindir}/portify"
  rm -f "$tmp"

  echo "✓ Installed: ${bindir}/portify"
  if ! command -v portify &>/dev/null; then
    echo ""
    echo "⚠  ${bindir} isn't on your PATH yet. Add this to ~/.zshrc or ~/.bashrc:"
    echo "    export PATH=\"${bindir}:\$PATH\""
  fi
  echo ""
  echo "Try:  portify --help   then   portify --scan --apply"
}

main "$@"
