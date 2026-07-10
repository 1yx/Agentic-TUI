# worktrunk — shell integration
if status --is-interactive; and command -v wt >/dev/null 2>&1
    wt config shell init fish | source
end
