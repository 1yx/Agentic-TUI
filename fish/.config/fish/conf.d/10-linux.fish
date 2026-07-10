# Linux-only PATH and environment. Self-guards on _os (set by 00-os.fish).
if test "$_os" = linux
    # pnpm — single source of truth for Linux (XDG ~/.local/share layout).
    # v11+ puts global shims in $PNPM_HOME/bin, not $PNPM_HOME.
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    fish_add_path "$PNPM_HOME/bin"
end
