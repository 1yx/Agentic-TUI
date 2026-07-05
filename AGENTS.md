# Agentic-TUI

Agent-native dotfiles for a high-performance TUI development OS on macOS.

## Purpose

This repo manages config for:

- `cmux`
- `ghostty`
- `fish`
- `helix`
- `yazi`
- `lazygit`
- `starship`
- `git`
- `worktrunk`
- `claude`
- `gemini`
- `uv`

It uses GNU Stow. Each top-level directory is one stow package.

## Agent Setup Instructions

> **Fast Track**: If you want to skip all interactive choices and apply the **Recommended Defaults** (SpecKit, Sibling Worktrees, cld.fish), refer the Agent to [**ONESHOT.md**](./ONESHOT.md) instead.

When an AI Agent is invoked to set up this environment, it MUST execute the following steps strictly:

### 1. Pre-flight Checks
- **OS Requirement**: Verify the OS is macOS (`uname -s` == `Darwin`). If not, halt and inform the user.
- **Homebrew**: Verify `brew` is installed (`command -v brew`). If missing, halt and ask the user to install it.
- **Current Shell**: Check the current shell (`echo $SHELL`). If it is not `fish`, inspect and record the user's current shell configuration (e.g., `.zshrc`, `.bashrc` aliases, exports, and paths). The agent must then adapt and recreate these configurations in `fish` syntax during the setup.

### 2. Dependencies Installation
#### Install the required toolchain using Homebrew:
```bash
# Core TUI tools
brew install stow helix yazi lazygit fish starship fd

# GNU toolchain (macOS built-ins are BSD; use g-prefixed binaries: gsed, gawk, gdate,
# ggrep, gfind, gxargs, gtar, gwhich, gindent, gtimeout, getopt, etc.)
brew install coreutils gnu-sed gawk findutils gnu-tar grep gnu-which gnu-indent gnu-getopt
```
The `g`-prefixed binaries land in `/opt/homebrew/bin` (already on `PATH` via `config.fish`), so they're available to fish and to any process launched from it (including pi's bash tool, which inherits the exported `PATH`). Bare names (`sed`, `awk`, `date`, ...) intentionally stay the BSD system defaults — no `gnubin` PATH override.

#### Switch to Fish and fix PATH
If the pre-flight check (§1) determined the current shell is **not** fish, the agent **MUST**:
1. Add fish to `/etc/shells`: `echo (brew --prefix)/bin/fish | sudo tee -a /etc/shells`
2. Set fish as default shell: `chsh -s (brew --prefix)/bin/fish`
3. Ensure Homebrew paths are correct in fish. Add to the repo's `fish/.config/fish/config.fish` (not `~/.config/fish/` — Stow will symlink it later):
   ```fish
   # Homebrew
   /opt/homebrew/bin/brew shellenv | source
   ```
   This step is critical because Homebrew-installed tools (helix, yazi, starship, etc.) will not be found in PATH without it.

#### Install spec-driven development tool (choose one)
The agent **MUST** ask the user which spec tool they prefer:

- **OpenSpec** (requires Node.js — ask user for npm/pnpm/yarn):
  ```bash
  <npm|pnpm|yarn> install -g @fission-ai/openspec@latest
  ```
- **SpecKit** (requires Python/uv):
  ```bash
  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
  ```

#### Install cmux
```bash
brew tap manaflow-ai/cmux
brew install --cask cmux
```

#### Install worktrunk
```
brew install worktrunk
wt config shell install
```

After installing worktrunk, the agent **MUST** ask the user to choose a worktree directory structure.

The `worktree-path` setting in `~/.config/worktrunk/config.toml` controls where new worktrees are created. Available variables: `{{ main_worktree }}` (repo directory name), `{{ branch }}` (branch name, slashes → dashes).

- **Option A: Sibling/Flat (Recommended)**
  Worktrees are created alongside the main repository (e.g., `~/code/myproject.feature-login`).
  *Best for*: Complete isolation and parallel AI Agent execution.
  *Config*: `worktree-path = "../{{ main_worktree }}.{{ branch }}"`

- **Option B: Nested/Hidden**
  Worktrees are kept within a sub-directory of the main repository (e.g., `~/code/myproject/.worktrees/feature-login`).
  *Best for*: Keeping the project self-contained in one parent folder.
  *Config*: `worktree-path = ".worktrees/{{ branch }}"`

- **Option C: Namespaced**
  All worktrees are collected under a shared `../worktrees/<project>/` directory (e.g., `~/code/worktrees/myproject/feature-login`).
  *Best for*: Multiple repos sharing the same parent directory — keeps parent folder clean.
  *Config*: `worktree-path = "../worktrees/{{ main_worktree }}/{{ branch }}"`

The agent MUST set the user's chosen `worktree-path` in the repo's `worktrunk/.config/worktrunk/config.toml` (not `~/.config/worktrunk/` — Stow will symlink it later).

### 3. Stow Deployment
- **Pre-check & Backup**: Before symlinking, check if any of the following paths exist as real directories/files (not symlinks):
  ```
  ~/.config/ghostty
  ~/Library/Application Support/com.mitchellh.ghostty
  ~/.config/fish
  ~/.config/helix
  ~/.config/yazi
  ~/.config/lazygit
  ~/Library/Application Support/lazygit
  ~/.config/starship.toml
  ~/.gitconfig
  ~/.config/git/config
  ~/.config/git/ignore
  ~/.config/worktrunk
  ~/.config/cmux
  ~/.claude
  ~/Library/Application Support/Claude/claude_desktop_config.json
  ~/.gemini
  ```
  For each existing path, apply the following logic:
  1. **`.backup/` exists and is up-to-date**: The user already ran `backup_configs.sh`. Safe to delete the original and proceed.
  2. **`.backup/` exists but is stale**: Halt and alert the user — a previous backup exists but has diverged. Ask the user how to proceed (e.g., overwrite `.backup/`, or skip). After resolving, delete the original config paths that are real directories (not symlinks) so that Stow can create symlinks in their place.
  3. **No `.backup/` exists**: Run `bash backup_configs.sh` from the repo root to create backups in `.backup/`, then delete the original config paths that are real directories (not symlinks) so that Stow can create symlinks in their place.
- **Config Merging**: After backing up, the agent MUST attempt to merge the user's existing configurations for **ALL tools** (e.g., Helix, Yazi, LazyGit, Git, Fish) into the corresponding files **within the cloned repository's directory** (not `~`). The merged configs live in the repo, then Stow creates symlinks from `~` to the repo during deployment.
- **Conflict Resolution**: If a conflict arises during merging (e.g., conflicting keybinds or aliases), the agent MUST NOT make a silent choice. Instead, ask the user an open-ended question to determine the desired behavior for that specific tool's configuration.
- **Keymap Generation**: After merging, the agent MUST regenerate `KEYMAP.md` based on the final merged configurations. During this process, perform a **collision check** across all tools (e.g., ensuring a Helix shortcut doesn't conflict with a global or cmux shortcut). If conflicts are found, notify the user and guide them through a resolution. To inspect each tool's keybindings during collision check:

  ```bash
  # cmux（no CLI to print all shortcuts; see command palette ⌘⇧P and CLAUDE.md "cmux 原生快捷键"）
  cmux --help

  # Ghostty（view full active config including keybinds; fails if not installed）
  ghostty +show-config

  # Helix（CLI gives help/tutorial entry; full defaults via tutor / built-in help）
  hx --help
  hx --tutor

  # Yazi（no "print all shortcuts" CLI; project custom keys in repo keymap）
  yazi --help
  sed -n '1,200p' yazi/.config/yazi/keymap.toml

  # Fish（no unified shortcut table; use `bind` in interactive session）
  fish --help
  fish -C bind -C exit

  # LazyGit（help and defaults in-app; keys via help panel）
  lazygit --help
  lazygit --config

  # Starship（no shortcut system; print prompt config）
  STARSHIP_CONFIG="$(pwd)/starship/.config/starship.toml" starship print-config

  # worktrunk（no shortcuts; CLI subcommands）
  wt --help
  ```

  Note: Project custom keybindings are primarily in `helix/.config/helix/config.toml` and `yazi/.config/yazi/keymap.toml`. Full default keymaps for cmux, Ghostty, Helix, Yazi, LazyGit are best viewed via in-app help/tutorial/command palette.
- **Deployment**: Execute the Stow commands from the root of this repository (dry-run first to verify):
  ```bash
  stow -n -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk cmux uv claude gemini
  stow -v --target="$HOME" ghostty helix yazi fish starship lazygit git worktrunk cmux uv claude gemini
  ```

  **Package-specific notes**:
  - **fish**: `fish_variables` is auto-modified by Fish at runtime (`set -U`). It is NOT tracked in the stow package. The fish package uses file-level symlinks for `config.fish` and `functions/*.fish`, while `fish_variables` remains a standalone local file in `~/.config/fish/`.
  - **claude**: Manages `settings.json`, `keybindings.json`, `hooks/`, `commands/`, and `skills/` via stow. Runtime data (`sessions/`, `history.jsonl`, `cache/`, etc.) is not tracked.

### 4. Post-setup & Initialization

#### XDG Compatibility
LazyGit and Git on macOS do not use `~/.config/` by default. Fish environment variables (already in `fish/.config/fish/config.fish`) handle this:
```fish
set -gx XDG_CONFIG_HOME ~/.config           # LazyGit reads this
set -gx GIT_CONFIG_GLOBAL ~/.config/git/config  # Git reads this
```
Claude hardcodes `~/.claude/` and cannot be changed — the only exception.

#### Git Identity Setup
The repo tracks a placeholder template at `git/.config/git/config` (`YOUR_NAME` / `your@email.com`). If these values are still placeholders, the agent **MUST** guide the user through:
1. Edit `git/.config/git/config` with real name and email
2. `stow -R -v --target="$HOME" git`
3. `git update-index --skip-worktree git/.config/git/config` (prevents personal info from being committed)

#### Claude Code Configuration
The agent **MUST** ask the user to choose one of the following provider switching methods:

**Option A: `cld` (built-in fish function)**
The repo includes `fish/.config/fish/functions/cld.fish` — a single fish function with provider argument. All API keys and base URLs are read from Fish universal variables, so `cld.fish` contains no secrets and can be safely committed.
```
cld glm "prompt"    # Use GLM provider
cld kimi            # Use Kimi provider
cld proxy           # Use custom proxy
```
To set up providers, configure the following Fish universal variables (persist across sessions, stored in `~/.config/fish/fish_variables`):
```fish
set -Ux CLD_PROXY_URL https://your-proxy.example.com
set -Ux CLD_PROXY_TOKEN your-proxy-token
set -Ux CLD_GLM_URL https://open.bigmodel.cn/api/anthropic
set -Ux CLD_GLM_TOKEN your-glm-token
set -Ux CLD_KIMI_URL https://api.kimi.com/coding/
set -Ux CLD_KIMI_KEY your-kimi-key
set -Ux CLD_OPENROUTER_URL https://openrouter.ai/api
set -Ux CLD_OPENROUTER_TOKEN your-openrouter-token
```
To add a new provider, add a `case` block in `cld.fish` and set the corresponding `CLD_*_URL` and `CLD_*_TOKEN` universal variables.

**Option B: claude-code-router (`ccr`)**
A proxy router that routes Claude Code requests to different providers by task type. Install and configure:
```bash
npm install -g @musistudio/claude-code-router
ccr start           # Starts proxy on 127.0.0.1:3456
ccr code            # Launch claude through router
```
Config at `~/.claude-code-router/config.json`. Supports per-task-type model routing, `/model provider,model` switching inside claude, and `ccr ui` web dashboard.

**Default Permissions**

This repo pre-configures Claude Code permissions in `claude/.claude/settings.json` (symlinked to `~/.claude/settings.json`). The agent **MUST** ask the user to review these permissions and adjust to their comfort level. Key points:
- Auto-allowed: `git`, `pnpm`, `bun`, `node`, `npx`, `uv`, `openspec`, `specify`, `cmux`, read-only filesystem commands, `WebSearch`/`WebFetch`, MCP tools.
- Always denied (requires human confirmation): `git push`, `npm`.
- To modify: edit `permissions.allow` or `permissions.deny` arrays in `claude/.claude/settings.json`.

**Keybindings**

`claude/.claude/keybindings.json` (symlinked to `~/.claude/keybindings.json`) defines custom keybindings for Claude Code. Current custom bindings:
- `Ctrl+J` → `chat:newline` (insert newline, same as Shift+Enter)

To add or modify keybindings, edit `claude/.claude/keybindings.json`. See `/doctor` to validate.

#### Spec-Driven Development
The spec tool was installed in §2. Here is the workflow for each:

**OpenSpec** workflow uses Claude Code skills (slash commands): `/opsx:propose` → specs → design → tasks → `/opsx:apply` → implement → `/opsx:archive`. Initialize with `openspec init --tools claude`. Changes are stored in `openspec/changes/<name>/`.

**SpecKit** workflow uses Claude Code skills (slash commands): `/speckit.specify` → `/speckit.clarify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`. Initialize with `specify init <project_name>`. Spec artifacts are stored in `.spe-kit/` directory. Configuration at `.spe-kit/constitution.md`.

#### Dev Workflow Summary
The repo provides a unified 5-step `dev` workflow that maps to both OpenSpec and SpecKit:

| Step | Command | OpenSpec | SpecKit |
|------|---------|----------|---------|
| 1. init | `dev init` | `openspec init` | `specify init` |
| 2. specify | `dev specify <name>` | `/opsx:explore` → `/opsx:propose` | `specify specify` → `clarify` |
| 3. plan | `dev plan` | (already in propose) → review-doc | `specify plan` → `tasks` → review-doc |
| 4. implement | `dev implement` | `/opsx:apply` → review-code → commit | `specify implement` → review-code → commit |
| 5. archive | `dev archive` | `/opsx:archive` → push → close → remove | push → close → remove |

Flow:
```
dev init              ← Step 1: spec tool init + 3-pane layout
dev specify <name>    ← Step 2: wt new + layout + explore + proposal
dev plan              ← Step 3: plan + tasks + review-doc + commit
dev implement         ← Step 4: apply + review-code + commit
dev archive           ← Step 5: archive + push + close workspace + remove worktree
```

Key behaviors:
- **`dev specify`** creates a worktree (`wt switch -c`) and initializes the 3-pane layout.
- **`dev plan`** generates technical plan, then runs `review-doc` (AI reviews spec documents) and commits.
- **`dev implement`** applies changes, then runs `review-code` (AI reviews code diff) and commits.
- **`dev archive`** pushes to remote, closes the cmux workspace, and removes the worktree (`wt remove`).
- Commits happen after `review-doc` (step 3) and `review-code` (step 4), but push only happens in `archive` (step 5).

The `dev` commands use `cld` for AI prompts. The agent **MUST** advise the user that these are templates and should be modified in `fish/.config/fish/functions/` to match their specific team or project requirements.

### 5. Smoke Tests
Run the following commands from the project root to verify each tool's configuration:

```bash
# Ghostty（built-in show-config; will fail if ghostty is not installed）
ghostty +show-config --default --docs >/dev/null

# Stow（confirm command is available）
stow --version

# Helix（load project config explicitly）
hx --config "$(pwd)/helix/.config/helix/config.toml" --health

# Yazi（no standalone validate subcommand; smoke test with custom config dir）
YAZI_CONFIG_HOME="$(pwd)/yazi/.config/yazi" yazi --debug

# Fish（syntax check）
fish -n fish/.config/fish/config.fish
fish -n fish/.config/fish/functions/*.fish

# LazyGit（no standalone lint subcommand; load project config for smoke test）
lazygit --use-config-file "$(pwd)/lazygit/.config/lazygit/config.yml" --debug

# Starship（load project config explicitly）
STARSHIP_CONFIG="$(pwd)/starship/.config/starship.toml" starship explain

# worktrunk（point XDG_CONFIG_HOME to project config）
XDG_CONFIG_HOME="$(pwd)/worktrunk/.config" wt config show >/dev/null

# Git（parse project-local git config）
git config --file "$(pwd)/git/.config/git/config" --list >/dev/null

# Claude settings / hooks / keybindings
jq empty claude/.claude/settings.json
jq empty claude/.claude/keybindings.json
bash -n claude/.claude/hooks/cmux-notify.sh

# uv（confirm available and verify config loads）
uv --version
cat uv/.config/uv/uv.toml
```

Notes:
- `yazi --debug` and `lazygit --debug` will enter interactive mode; the goal is to confirm no config parse errors on startup.
- `wt config show` reads `XDG_CONFIG_HOME/worktrunk/config.toml`, hence the override above.

### 6. Launch & Explore
Setup is complete. The agent **MUST** now guide the user to:
1. Open the **cmux** app.
2. `cd` into this project directory.
3. Start a Claude session inside cmux using `dev *` or `cld *` or `claude`.
4. Ask Claude about any tool's shortcuts, keybindings, or configuration details (e.g. "show me helix keymap", "what does ⌘D do in cmux", "explain the dev workflow").
5. Request modifications to fit the user's own preferences — Claude will edit the stow packages and restow as needed.
6. Before pushing to a remote repository, remind the user to protect sensitive data (API keys, tokens, secrets). Use `git update-index --skip-worktree <file>` on any file containing real credentials to prevent accidental commits.

#### Keymap & Shortcut Viewing
Remind the user that `KEYMAP.md` in the project root is the single-page cheatsheet for all tool keybindings and custom overrides. If the user has any questions about shortcuts or keybindings (e.g. "what does ⌘D do in cmux", "show me helix keymap"), they can ask the agent at any time.