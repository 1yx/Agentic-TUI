# Linux-only PATH and environment. Self-guards on _os (set by 00-os.fish).
if test "$_os" = linux
    # pnpm — single source of truth for Linux (XDG ~/.local/share layout).
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    if not contains $PNPM_HOME $PATH
        set -gx PATH $PNPM_HOME $PATH
    end
end
