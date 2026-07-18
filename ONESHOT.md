# One-shot Agent Setup (Opinionated Defaults)

This document provides a streamlined, zero-interaction setup path for AI Agents. It follows the core logic of `AGENTS.md` but skips all user prompts by applying the project's **Recommended Defaults**.

## Opinionated Defaults Table

| Choice | Default Selection | Reason |
|--------|-------------------|--------|
| **Spec Tool** | **SpecKit** (via `uv`) | Modern, fast installation, minimal Python dependencies. |
| **Worktree Path** | **Sibling/Flat** (`../{{ main_worktree }}.{{ branch }}`) | Best isolation for parallel AI Agent execution. |
| **Claude Provider** | **cld.fish** (built-in) | Zero external dependencies, native Fish integration. |
| **Permissions** | **Project Defaults** | Auto-approve the recommended `claude/.claude/settings.json`. |

## Execution Logic for Agents

When an Agent is instructed to perform a "One-shot Setup", it MUST execute these steps strictly without asking for confirmation:

### 1. Pre-flight & Core Install
- Verify macOS (`Darwin`) and `brew`.
- Install core toolchain: `brew install stow helix yazi lazygit fish starship fd uv`.
- Install GNU toolchain: `brew install coreutils gnu-sed gawk findutils gnu-tar grep gnu-which gnu-indent gnu-getopt`.
- Install `cmux`: `brew tap manaflow-ai/cmux && brew install --cask cmux`.
- Install `worktrunk`: `brew install worktrunk && wt config shell install`.
- **Fish Default**: Set Fish as default shell and ensure `brew shellenv` is in `fish/.config/fish/config.fish`.

### 2. Dependency Setup (Automatic)
- **SpecKit**: Execute `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`.
- **Worktree Config**: Force set `worktree-path = "../{{ main_worktree }}.{{ branch }}"` in `worktrunk/.config/worktrunk/config.toml`.

### 3. Deployment (Forceful)
- **Backup**: Run `bash backup_configs.sh`.
- **Clean**: Delete any existing real directories/files (not symlinks) that conflict with Stow (see list in `AGENTS.md` §3).
- **Deploy**: Execute `./install.sh --apply`. The package set comes from `packages.manifest`; do not hardcode a separate stow package list.

### 4. Initialization
- **XDG & Git**: Ensure `XDG_CONFIG_HOME` is exported in `config.fish`. Do **not** set `GIT_CONFIG_GLOBAL` — it would make git ignore `~/.gitconfig` (where personal identity lives). Git reads `~/.config/git/config` natively once stowed.
- **SpecKit Init**: Run `specify init (basename (pwd))` in the repository root.
- **Git Identity**: Write real identity (name/email/signingkey/proxy/editor) into `~/.gitconfig` — it overrides the stowed `~/.config/git/config` per-key (see `AGENTS.md` §4 load order). No `skip-worktree` needed; `~/.gitconfig` lives outside the repo.
- **Keymap**: Generate `KEYMAP.md` based on current repo configs.

### 5. Validation (Smoke Tests)
- Run all smoke tests defined in `AGENTS.md` §5.
- If deployment fails due to existing real config files, re-run `bash backup_configs.sh`, clear the conflicting real paths as described in `AGENTS.md` §3, then retry `./install.sh --apply` once before reporting the error.

### 6. Completion
- Notify the user via `cmux notify` (if available) or standard output: 
  > "One-shot setup complete! Using SpecKit, Sibling Worktrees, and cld.fish. Open **cmux** to begin."
