# Erase inherited GIT_CONFIG_GLOBAL: long-running parents (cmux/ghostty
# launched under an older fish revision) may still export it, which makes
# git read ONLY ~/.config/git/config and ignore ~/.gitconfig — where personal
# identity lives (AGENTS.md §4 Git Identity Setup). Erase on every shell
# start so git's native 4-level config load order works regardless of parent.
set -e GIT_CONFIG_GLOBAL
