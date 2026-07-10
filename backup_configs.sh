#!/usr/bin/env bash
#
# backup_configs.sh — back up existing user configs into .backup/.
#
# Platform-aware: macOS ~/Library/Application Support/... paths are included only
# on Darwin. The package list is derived from packages.manifest (single source of
# truth, shared with install.sh) — column 4 holds per-package, comma-separated,
# $HOME-relative backup paths.
#
# Portability: bash 3.2-compatible (no associative arrays / mapfile).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
MANIFEST="${PACKAGES_MANIFEST:-$SCRIPT_DIR/packages.manifest}"
BACKUP_DIR="$SCRIPT_DIR/.backup"

[ -f "$MANIFEST" ] || { echo "backup_configs.sh: manifest not found: $MANIFEST" >&2; exit 2; }

os="$(uname -s | tr '[:upper:]' '[:lower:]')"   # darwin | linux

# Build the backup path list from manifest column 4 (current platform only).
paths=()
while IFS=$'\t' read -r pkg binary platform backup || [ -n "$pkg" ]; do
  case "$pkg" in ''|\#*) continue ;; esac
  # skip packages not eligible on this OS
  [ "$platform" != "any" ] && [ "$platform" != "$os" ] && continue
  [ -z "$backup" ] && continue
  IFS=',' read -ra parts <<< "$backup"  # bash: lowercase -a = read into array
  paths+=("${parts[@]}")
done < "$MANIFEST"

# macOS-only app-support paths (not 1:1 with a stow package; OS-gated).
if [ "$os" = "darwin" ]; then
  paths+=(
    "Library/Application Support/com.mitchellh.ghostty"
    "Library/Application Support/lazygit"
    "Library/Application Support/Claude/claude_desktop_config.json"
  )
fi

echo "Starting configuration backup -> .backup/   (OS: $os, ${#paths[@]} paths)"

for rel in ${paths[@]+"${paths[@]}"}; do
  src="$HOME/$rel"
  dest="$BACKUP_DIR/$rel"
  if [ -e "$src" ] || [ -L "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    if cp -RL "$src" "$dest" 2>/dev/null; then
      echo "  OK  ~/$rel"
    else
      echo "  WARN copy failed: ~/$rel"
    fi
  else
    echo "  --  not found: ~/$rel (skipping)"
  fi
done

echo "Backup complete. Files saved in .backup/"
