# ~/.config/fish/config.fish

# Disable the fish greeting.
set -g fish_greeting

# Disable mail check notices.
set -e MAILCHECK

# Homebrew
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin

# Local bin
fish_add_path "$HOME/.local/bin"

# XDG base directories.
set -gx XDG_CONFIG_HOME ~/.config
set -gx GIT_CONFIG_GLOBAL ~/.config/git/config

# Default editors.
set -gx EDITOR hx
set -gx GIT_EDITOR hx
set -gx VISUAL hx

# Sync the shell cwd with the last directory visited in Yazi.
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -gx PNPM_HOME "$HOME/Library/pnpm"
if not contains $PNPM_HOME $PATH
    set -gx PATH $PNPM_HOME $PATH
end

# Google Cloud SDK
set -gx CLOUDSDK_PYTHON "/opt/homebrew/opt/python@3.11/libexec/bin/python"
if test -f "$HOME/tmp/google-cloud-sdk/path.fish.inc"
    source "$HOME/tmp/google-cloud-sdk/path.fish.inc"
end

# mysql-client
fish_add_path /opt/homebrew/opt/mysql-client/bin

# postgresql@17
fish_add_path /opt/homebrew/opt/postgresql@17/bin

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# emacs
function e
    if not TERM=xterm-256color emacsclient -n -e "(+ 1 1)" >/dev/null 2>&1
        echo "Starting Emacs daemon..."
        emacs --daemon
    end
    TERM=xterm-256color emacsclient -t $argv
end

# coreutils (GNU timeout)
fish_add_path /opt/homebrew/opt/coreutils/libexec/gnubin
abbr -a timeout gtimeout

# GNU which/indent (g-prefixed → default names via gnubin)
fish_add_path /opt/homebrew/opt/gnu-which/libexec/gnubin
fish_add_path /opt/homebrew/opt/gnu-indent/libexec/gnubin

# GNU getopt (keg-only, needs explicit PATH)
fish_add_path /opt/homebrew/opt/gnu-getopt/bin

# Obsidian
fish_add_path /Applications/Obsidian.app/Contents/MacOS

# DO_NOT_TRACK
set -gx DO_NOT_TRACK 1

# Interactive-only tooling initialization.
if status --is-interactive
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

    if command -v fnm >/dev/null 2>&1
        fnm env --use-on-cd | source
    end

    if command -v corepack >/dev/null 2>&1
        corepack enable
        corepack prepare pnpm@latest --activate >/dev/null 2>&1
    end

    if command -v rbenv >/dev/null 2>&1
        rbenv init - fish | source
    end

    if command -v zoxide >/dev/null 2>&1
        zoxide init fish | source
    end

    if command -v uv >/dev/null 2>&1
        set -gx UV_MANAGED_PYTHON 1
    end

    if command -v wt >/dev/null 2>&1
        wt config shell init fish | source
    end

    # cmux workspace metadata refresh on every prompt
    if not functions -q __cmux_prompt_base
        functions --copy fish_prompt __cmux_prompt_base
        function fish_prompt
            _cmux_meta_refresh
            __cmux_prompt_base
        end
    end
end

# pnpm
set -gx PNPM_HOME "/Users/dontaire/Library/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# Pi
fish_add_path "/Users/dontaire/.local/share/fnm/node-versions/v24.14.1/installation/bin"
