# Global Instructions

## Tool Preferences

- Prefer `pnpm` over `npm` for all Node.js package management tasks
- Prefer `rg` over `grep` for text search
- Prefer `fd` over `find` for file search
- Prefer `jq` over `python3 -c 'import json...'` for JSON processing
- Prefer `uv` over `pip` for Python package management
- Prefer `gsed` over `sed` for GNU sed features (in-place editing without backup extension)
- Prefer `gawk` over `awk` for GNU awk features (strftime, FPAT, gensub, etc.)
- Prefer `gdate` over `date` for GNU date features (relative dates, iso-8601)
- Prefer `gstat` over `stat` for GNU stat features (format strings)
- Prefer `greadlink` over `readlink` for reliable -f canonicalize
- Prefer `grealpath` over `realpath` for path canonicalization
- Prefer `gtimeout` over `timeout` for command time-limiting
- Prefer `gfind` over `find` for GNU find features (but prefer `fd` over both)
- Prefer `gxargs` over `xargs` for GNU xargs features (-d, -P parallel)
- Prefer `gtar` over `tar` for GNU tar features (--exclude, --transform)
- Prefer `ggrep` over `grep` for GNU grep features (-P Perl regex) (but prefer `rg` over both)
- Prefer `gwhich` over `which` for GNU which features (-a list all matches)
- Prefer `gindent` over `indent` for GNU indent features
- Prefer `gnu-getopt` over `getopt` for long option parsing

> Claude Code uses zsh as its default shell, ignoring `chsh` configuration. Since macOS built-in tools differ from GNU counterparts, GNU tools must be installed via Homebrew and their gnubin PATH configured in `.zprofile`.
>
> Homebrew packages: `fd` `ripgrep` `jq` `coreutils` `gnu-sed` `gawk` `findutils` `gnu-tar` `grep` `gnu-which` `gnu-indent` `gnu-getopt`

## Editing Rules

- Use 2 spaces for indentation, never tabs (`^I`)
- Use the Edit tool to modify code, never `python3` one-liners. If a file has tab indentation, convert tabs to spaces first, then use Edit.

## Date and Time

- Run `date` to get the current date/time; do not rely on internal knowledge for temporal facts

## Tone and Style

- Welcome criticism, maintain skepticism, be concise — skip flattery and filler

## Research

- Always use MCP search tools (WebSearch, WebFetch) for research tasks; do not rely on internal knowledge for facts that may have changed

## Long-Running Tasks

- For long-running operations, manually retry with exponential backoff: 1 min → 2 min → 4 min
