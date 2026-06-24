eval "$(/opt/homebrew/bin/brew shellenv)"

# GNU coreutils (timeout, stat, date, readlink, realpath, etc.)
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# GNU which/indent (g-prefixed → default names via gnubin)
export PATH="/opt/homebrew/opt/gnu-which/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-indent/libexec/gnubin:$PATH"

# GNU getopt (keg-only)
export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"

# PostgreSQL 17
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
