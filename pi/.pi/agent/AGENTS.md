# 全局偏好

- 不要在代码里加 `ponytail:` 注释、TODO 标记或类似的"元注释"。需要说明就写正常注释。
  - 覆盖 `~/.pi/agent/git/github.com/DietrichGebert/ponytail/skills/ponytail/SKILL.md`「Rules」中原有的
    “Mark deliberate simplifications with a `ponytail:` comment …” 一行（该行已手动删除）。
    上游包更新若回滚此删除，由本条全局指令覆盖兜底。

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
- Prefer `getopt` from brew `gnu-getopt` over BSD `getopt` for long option parsing (keg-only; binary is `getopt`, in `/opt/homebrew/opt/gnu-getopt/bin`)

> macOS built-in tools are BSD and differ from GNU counterparts. GNU tools are installed via Homebrew and used via their `g`-prefixed binaries (`gsed`, `gawk`, `gdate`, ...) in `/opt/homebrew/bin`; bare names intentionally stay the BSD system defaults. The agent must use the `g`-prefixed form.
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
