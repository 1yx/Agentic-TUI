# OS detection — runs first (lexicographically), sets _os for downstream modules.
# Generic Linux: no distro distinction (per design Decision 3).
# Values: "darwin" | "linux"
set -g _os (uname -s | string lower)
