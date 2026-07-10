#!/usr/bin/env fish
#
# One-time migration for pnpm global packages installed with the old global/5
# layout. Installs the direct global dependencies into the current pnpm global
# root, then removes stale top-level shims that still point at global/5.

set -l mode apply
if test (count $argv) -gt 0
    switch "$argv[1]"
        case --dry-run
            set mode dry-run
        case -h --help
            echo "Usage: scripts/migrate-pnpm-global-5-to-v11.fish [--dry-run]"
            exit 0
        case '*'
            echo "Unknown option: $argv[1]" >&2
            exit 2
    end
end

set -l pnpm_home
if set -q PNPM_HOME
    set pnpm_home $PNPM_HOME
else
    set pnpm_home "$HOME/Library/pnpm"
end

set -l old_global "$pnpm_home/global/5"
set -l manifest "$old_global/package.json"

if not test -f "$manifest"
    echo "No old pnpm global manifest found: $manifest" >&2
    exit 1
end

if not command -q pnpm
    echo "pnpm not found on PATH" >&2
    exit 1
end

if not command -q jq
    echo "jq not found on PATH" >&2
    exit 1
end

set -gx PNPM_HOME "$pnpm_home"
if not contains -- "$PNPM_HOME/bin" $PATH
    set -gx PATH "$PNPM_HOME/bin" $PATH
end

set -l packages
for name in (jq -r '.dependencies // {} | keys[]' "$manifest")
    set -a packages "$name@latest"
end

if test (count $packages) -eq 0
    echo "No dependencies found in $manifest"
    exit 0
end

set -l stale_shims
for f in "$pnpm_home"/* "$pnpm_home"/bin/*
    if test -f "$f"; and test -x "$f"; and command grep -q "$pnpm_home/global/5/" "$f" 2>/dev/null
        set -a stale_shims "$f"
    end
end

echo "pnpm home: $pnpm_home"
echo "old global: $old_global"
echo "packages to install:"
for pkg in $packages
    echo "  + $pkg"
end

echo "stale shims to remove:"
if test (count $stale_shims) -gt 0
    for shim in $stale_shims
        echo "  - $shim"
    end
else
    echo "  (none)"
end

if test "$mode" = dry-run
    exit 0
end

if command -q corepack
    corepack enable; or exit 1
    corepack prepare pnpm@latest-11 --activate; or exit 1
end

pnpm install -g $packages; or exit 1

for installer in (find -L (pnpm root -g) -path '*/node_modules/@anthropic-ai/claude-code/install.cjs' -print 2>/dev/null)
    node "$installer"; or exit 1
end

if test (count $stale_shims) -gt 0
    rm -- $stale_shims; or exit 1
end

echo "Migration complete."
echo "Open a new shell, then run:"
echo "  pnpm list -g --depth 0"
