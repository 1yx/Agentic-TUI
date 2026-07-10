# starship prompt
if status --is-interactive; and command -v starship >/dev/null 2>&1
    starship init fish | source
end
