#!/usr/bin/env bash
# Remove the portify script (does NOT delete your ports.yaml registry).
set -euo pipefail
for dir in /usr/local/bin "$HOME/.local/bin"; do
  if [[ -f "$dir/portify" ]]; then
    if [[ -w "$dir" ]]; then rm -f "$dir/portify"; else sudo rm -f "$dir/portify"; fi
    echo "✓ Removed $dir/portify"
  fi
done
echo "Your registry (PORTS_FILE, default ~/.ports/ports.yaml) was left untouched."
