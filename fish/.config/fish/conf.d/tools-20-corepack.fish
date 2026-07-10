# corepack — enable pnpm via Node's corepack
if status --is-interactive; and command -v corepack >/dev/null 2>&1
    corepack enable
    corepack prepare pnpm@latest --activate >/dev/null 2>&1
end
