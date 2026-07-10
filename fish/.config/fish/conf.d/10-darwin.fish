# macOS-only PATH and environment. Self-guards on _os (set by 00-os.fish).
if test "$_os" = darwin
    # Homebrew
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin

    # pnpm — single source of truth for macOS (Library layout).
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    if not contains $PNPM_HOME $PATH
        set -gx PATH $PNPM_HOME $PATH
    end

    # Google Cloud SDK
    set -gx CLOUDSDK_PYTHON "/opt/homebrew/opt/python@3.11/libexec/bin/python"
    if test -f "$HOME/tmp/google-cloud-sdk/path.fish.inc"
        source "$HOME/tmp/google-cloud-sdk/path.fish.inc"
    end

    # Homebrew keg-only formulae
    fish_add_path /opt/homebrew/opt/mysql-client/bin
    fish_add_path /opt/homebrew/opt/postgresql@17/bin

    # Obsidian CLI shim
    fish_add_path /Applications/Obsidian.app/Contents/MacOS

    # GNU tools are used via g-prefixed binaries (gsed, gawk, gdate, ...) in /opt/homebrew/bin.
    # Bare names intentionally stay the BSD system defaults — no gnubin PATH override.
end
