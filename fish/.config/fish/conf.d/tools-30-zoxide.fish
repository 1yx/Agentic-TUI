# zoxide — smarter cd
if status --is-interactive; and command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end
