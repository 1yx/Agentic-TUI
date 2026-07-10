# ~/.config/fish/config.fish
# Platform-agnostic core.
# Platform-specific PATH/env live in conf.d/10-darwin.fish & conf.d/10-linux.fish;
# per-tool integrations live in conf.d/tools-*.fish (all auto-sourced before this file).
# _os is set by conf.d/00-os.fish (verified: conf.d/* run before config.fish).

# Disable the fish greeting.
set -g fish_greeting

# Disable mail check notices.
set -e MAILCHECK

# Local bin (cross-platform).
fish_add_path "$HOME/.local/bin"

# XDG base directories.
set -gx XDG_CONFIG_HOME ~/.config
set -gx GIT_CONFIG_GLOBAL ~/.config/git/config

# Default editors.
set -gx EDITOR hx
set -gx GIT_EDITOR hx
set -gx VISUAL hx

# bun (cross-platform layout).
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# DO_NOT_TRACK
set -gx DO_NOT_TRACK 1

# Sync the shell cwd with the last directory visited in Yazi.
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# emacsclient helper.
function e
    if not TERM=xterm-256color emacsclient -n -e "(+ 1 1)" >/dev/null 2>&1
        echo "Starting Emacs daemon..."
        emacs --daemon
    end
    TERM=xterm-256color emacsclient -t $argv
end

# cmux workspace metadata refresh on every prompt.
# Soft-loaded: only wraps fish_prompt when the cmux CLI is actually installed.
# Must run AFTER all prompt-definers (e.g. starship in conf.d/), so it lives at the
# end of config.fish (which runs after conf.d/* — verified fish 4.2.0 startup order).
if status --is-interactive; and command -v cmux >/dev/null 2>&1
    if not functions -q __cmux_prompt_base
        functions --copy fish_prompt __cmux_prompt_base
        function fish_prompt
            _cmux_meta_refresh
            __cmux_prompt_base
        end
    end
end
