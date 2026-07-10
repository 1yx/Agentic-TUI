# fnm (Fast Node Manager) — auto-switch Node on cd
if status --is-interactive; and command -v fnm >/dev/null 2>&1
    fnm env --use-on-cd | source
end
