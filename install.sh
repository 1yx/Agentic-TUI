#!/usr/bin/env bash
#
# install.sh — Agentic-TUI selective stow orchestrator.
#
# Stows each package in packages.manifest iff:
#   1. its <platform> field matches the current OS (any|darwin|linux), AND
#   2. its <gating-binary> is found via `command -v` (unless --ignore-presence).
#
# Modes / options:
#   (default)         dry-run — print the plan, change nothing
#   --apply           perform the stows (per-package; a conflict is reported, not fatal)
#   --check           doctor — report orphan package dirs & stale manifest entries
#   --target DIR      stow target directory (default: $HOME)
#   --ignore-presence also select packages whose gating binary is absent
#   -h, --help        show this help
#
# Manifest format (TAB-separated), shared with backup_configs.sh:
#   <package> <gating-binary> <platform> <backup-paths>
# (install.sh uses columns 1-3; backup_configs.sh uses columns 1 and 4.)
#
# Portability: written for bash 3.2 (macOS default /bin/bash) — no associative
# arrays, no mapfile; uses ${arr[@]+"${arr[@]}"} to survive `set -u` on empty arrays.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${PACKAGES_MANIFEST:-$SCRIPT_DIR/packages.manifest}"
TARGET="$HOME"
MODE="dryrun"
IGNORE_PRESENCE=0

usage() {
  cat <<'USAGE'
Usage: install.sh [--apply] [--check] [--target DIR] [--ignore-presence]
  (default)         dry-run: print selected/skipped packages, change nothing
  --apply           perform the stows (per-package; conflicts reported, not fatal)
  --check           doctor: report orphan dirs & stale entries (exit 1 if any found)
  --target DIR      stow target directory (default: $HOME)
  --ignore-presence also select packages whose gating binary is absent
  -h, --help        show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --apply)           MODE="apply" ;;
    --check)           MODE="check" ;;
    --target)          shift; TARGET="${1:?--target requires a value}" ;;
    --ignore-presence) IGNORE_PRESENCE=1 ;;
    -h|--help)         usage; exit 0 ;;
    *) echo "install.sh: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

[ -f "$MANIFEST" ] || { echo "install.sh: manifest not found: $MANIFEST" >&2; exit 2; }
command -v stow >/dev/null 2>&1 || { echo "install.sh: stow not found on PATH" >&2; exit 2; }

os="$(uname -s | tr '[:upper:]' '[:lower:]')"   # darwin | linux
has_bin() { command -v "$1" >/dev/null 2>&1; }

# Top-level dirs that are NOT stow packages (project scaffolding/data). Used only
# by --check to avoid false "orphan" reports.
NON_STOW_DIRS=(.git .backup openspec .pi node_modules .trash)
is_non_stow() { local x; for x in "${NON_STOW_DIRS[@]}"; do [ "$1" = "$x" ] && return 0; done; return 1; }

# --- read manifest: build selection + a space-joined manifest package set ---
selected=()
skipped=()
manifest_pkgs=""
while IFS=$'\t' read -r pkg binary platform _backup || [ -n "$pkg" ]; do
  case "$pkg" in ''|\#*) continue ;; esac        # skip blanks/comments
  manifest_pkgs="$manifest_pkgs $pkg"
  reason=""
  if [ "$platform" != "any" ] && [ "$platform" != "$os" ]; then
    reason="platform=$platform (host=$os)"
  elif [ "$IGNORE_PRESENCE" -eq 0 ] && ! has_bin "$binary"; then
    reason="no '$binary' on PATH"
  fi
  if [ -n "$reason" ]; then skipped+=("$pkg  ($reason)"); else selected+=("$pkg"); fi
done < "$MANIFEST"

case "$MODE" in
  dryrun)
    echo "OS: $os | target: $TARGET | manifest: $MANIFEST"
    echo "Selected (would stow): ${#selected[@]} package(s)"
    for p in ${selected[@]+"${selected[@]}"}; do echo "  + $p"; done
    echo "Skipped: ${#skipped[@]} package(s)"
    for s in ${skipped[@]+"${skipped[@]}"}; do echo "  - $s"; done
    ;;

  apply)
    echo "OS: $os | target: $TARGET | applying ${#selected[@]} package(s)..."
    [ "${#selected[@]}" -gt 0 ] || { echo "(nothing selected)"; exit 0; }
    rc=0
    for p in ${selected[@]+"${selected[@]}"}; do
      if stow -v --target="$TARGET" "$p"; then
        echo "  + stowed: $p"
      else
        echo "  ! conflict/error: $p (existing real file? run backup_configs.sh first)" >&2
        rc=1
      fi
    done
    exit $rc
    ;;

  check)
    echo "Manifest hygiene check (OS: $os)"
    # stale: manifest entry whose directory is missing
    echo "-- stale entries (in manifest, no directory on disk) --"
    stale=0
    for p in $manifest_pkgs; do
      [ -d "$SCRIPT_DIR/$p" ] || { echo "  ! $p"; stale=$((stale+1)); }
    done
    [ "$stale" -eq 0 ] && echo "  (none)"
    # orphan: top-level stow-style dir (has a dot entry) not in manifest & not known non-stow
    echo "-- orphan dirs (stow-style dir, not in manifest) --"
    orphans=0
    for d in "$SCRIPT_DIR"/*; do
      [ -d "$d" ] || continue
      name="$(basename "$d")"
      is_non_stow "$name" && continue
      # stow-style = has at least one top-level dot entry (e.g. .config, .gitconfig)
      [ -n "$(find "$d" -maxdepth 1 -mindepth 1 -name '.*' 2>/dev/null | head -1)" ] || continue
      case " $manifest_pkgs " in *" $name "*) : ;; *) echo "  ? $name"; orphans=$((orphans+1)); ;; esac
    done
    [ "$orphans" -eq 0 ] && echo "  (none)"
    echo "summary: $stale stale, $orphans orphan(s)"
    # Fail (non-zero) when issues are found so smoke tests / CI / agents detect a broken manifest.
    if [ "$stale" -gt 0 ] || [ "$orphans" -gt 0 ]; then
      exit 1
    fi
    ;;

  *)
    echo "install.sh: internal error: unknown mode '$MODE'" >&2; exit 3 ;;
esac
