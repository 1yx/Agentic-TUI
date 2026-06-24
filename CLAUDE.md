# Agentic-TUI — Agent-Native TUI Design Specification

> This document serves as a reference for project maintainers' AI Agent (e.g., Claude) instructions and design. For new user setup, see `AGENTS.md`.

## Stow Packages

This repository is managed using GNU Stow. Each top-level directory is a stow package:

`ghostty` `helix` `yazi` `fish` `zsh` `starship` `lazygit` `git` `worktrunk` `cmux` `tmux` `uv` `claude` `gemini`

After modifying any package, restow the corresponding package:
```bash
stow -R -v --target="$HOME" <package>
```

Detailed deployment process and directory structure can be found in `AGENTS.md`.

---

## Hierarchical Mapping (cmux concepts → Semantics)

```
Window    → Project (macOS window, ⌘⇧N to create; each window has an independent sidebar and workspace)
Workspace → Git Worktree / Branch (Sidebar tab, independent pane layout)
Pane      → Task Partition (⌘D right split / ⌘⇧D down split, ⌥⌘+arrow keys to navigate)
Surface   → Tool Tab (⌘T to create, ⌘[ / ⌘] / ⌘1-9 to navigate; each surface has an independent terminal session)
```

### Mapping Examples

| cmux Concept | Semantics         | Example                                 |
|--------------|-------------------|-----------------------------------------|
| Window       | Project           | myapp                                   |
| Workspace    | worktree / branch | myapp · main, myapp · feat/auth         |
| Pane         | Task Partition    | editor / agent / files                  |
| Surface      | Tool Tab          | agent pane: [claude] [test] [build]     |

### cmux CLI Command Cheat Sheet

```bash
# Workspace Management
cmux list-workspaces [--json]
cmux new-workspace                              # Create workspace
cmux select-workspace --workspace <id>           # Switch workspace
cmux current-workspace                           # Current workspace
cmux close-workspace --workspace <id>            # Close workspace

# Pane / Surface / Split
cmux list-panes                                  # List panes
cmux list-pane-surfaces --pane <id>              # List surfaces within a pane
cmux new-split right|down                        # Split pane
cmux rename-tab --surface <id> <name>            # Rename surface tab
cmux focus-pane --pane <id>                      # Focus pane

# Status / Notifications
cmux set-status <key> <status> --icon <icon> --color <hex>
cmux clear-status <key>
cmux list-status
cmux set-progress <0.0-1.0> --label <label>
cmux clear-progress
cmux notify --title <title> --body <body> --subtitle <subtitle>
```

---

## Standard Layout (3-Pane Asymmetric)

Each workspace uses a fixed 3-pane layout:

```
┌──────────────────────────┬──────────────┐
│                          │  claude      │
│       Helix              │  (AI Agent)  │
│       (code)             │              │
│                          ├──────────────┤
│                          │ Yazi/LazyGit │
│                          │ (files/git)  │
└──────────────────────────┴──────────────┘
```

### Responsibility Zones

| Pane   | Tool         | Responsibility                  |
|--------|--------------|---------------------------------|
| Left   | Helix        | Sole code editing entry point   |
| Top R  | claude       | Sole AI interface               |
| Bot R  | Yazi/LazyGit | File management + Version control|

All operations must pass through one of these three panes.
Pane ratios are adjusted via cmux drag-and-drop and saved, not hardcoded in scripts.

---

## Command System (dev CLI + Spec Tool)

### Command Set

```bash
# Environment Management (dev CLI / fish function)
dev init             # Initialize project: cmux window + default workspace + layout
dev wt new <name>    # Create worktree + workspace + layout (worktrunk + cmux integration)
dev wt go <name>     # Switch to specific workspace
dev wt finish        # Teardown: push, notify, close workspace, remove worktree
dev ai loop          # AI coding loop: claude analysis → generation → review diff
dev ai commit        # AI generated conventional commit message (with manual confirmation)
dev ai review        # AI review of current branch code (bugs/performance/readability)

# Specification-Driven Development — OpenSpec (Claude Code skills)
/opsx:propose "desc" # Planning: generate proposal → specs → design → tasks
/opsx:continue       # Progressive planning for each artifact
/opsx:ff             # Fast-forward: generate all planning artifacts (non-interactive)
/opsx:apply          # Execution: implement according to tasks.md
/opsx:archive        # Archival: merge specs, archive changes folder

# Specification-Driven Development — SpecKit (Claude Code skills)
/speckit.specify     # Requirement analysis: describe needs starting from constitution
/speckit.clarify     # Clarification: AI asks questions to complete requirement details
/speckit.plan        # Planning: generate technical solution
/speckit.tasks       # Decomposition: generate task list
/speckit.implement   # Execution: implement according to task list
```

### Relationship between Spec Tool and dev CLI

```
dev wt new <branch>          ← Create isolated environment
    ↓
  ┌─ OpenSpec ──────────────┐  ┌─ SpecKit ───────────────────┐
  │ /opsx:propose "desc"     │  │ /speckit.specify → clarify  │
  │ proposal → specs         │  │ constitution → Requirements  │
  │ → design → tasks         │  │ → /speckit.plan → tasks     │
  └──────────────────────────┘  └─────────────────────────────┘
    ↓
  ┌─ OpenSpec ─┐  ┌─ SpecKit ──────────────┐
  │ /opsx:apply│  │ /speckit.implement      │
  └────────────┘  └─────────────────────────┘
    ↓                          (Agent automatically reports status via cmux hooks)
dev ai loop                  ← Coding loop: claude analysis → patch → Helix refinement
    ↓
dev ai commit                ← AI generates commit message → manual confirmation → commit
    ↓
dev ai review                ← AI reviews current branch
    ↓
  ┌─ OpenSpec ──────┐  ┌─ SpecKit ──────────────┐
  │ /opsx:archive   │  │ (Direct commit + push)  │
  │ specs merged    │  └────────────────────────┘
  └──────────────────┘
    ↓
dev wt finish                ← Push + close workspace + remove worktree
```

### OpenSpec Directory Structure

```
openspec/
  config.yaml                # Project configuration (schema / context / rules)
  changes/
    <change-name>/
      proposal.md            # Why and what is changing
      specs/
        <domain>/spec.md     # Requirements + Scenarios (Given/When/Then)
      design.md              # Technical design
      tasks.md               # Implementation checklist
    archive/
      <date>-<change-name>/  # Archived changes
specs/                       # Source of truth for system behavior, merged from changes
```

### OpenSpec Configuration: `openspec/config.yaml`

```yaml
schema: spec-driven

context: |
  Agentic-TUI: cmux + Helix + claude + Yazi + LazyGit + Fish + Starship + Stow
  Hierarchy: Window(Project) → Workspace(worktree/branch) → Pane(Task Zone) → Surface(Tool Tab)
  Layout: 3-pane asymmetric (Left Helix 65%, Top-Right claude, Bottom-Right Yazi/LazyGit)
  Worktree Management: worktrunk (wt switch/remove/merge)
  Status Reporting: cmux set-progress / set-status / notify
  Editor: Helix, Version Control: LazyGit, File Manager: Yazi, Shell: Fish

rules:
  proposal:
    - Evaluate impact on existing cmux workspace layout
    - Specify which panes and tools are involved
  specs:
    - Use Given/When/Then format for scenarios
    - Distinguish between human operations and Agent automatic operations
  design:
    - List fish functions / config files requiring modification
    - Reference actual cmux CLI API commands if involved
  tasks:
    - Each task should not exceed 2 hours
    - Annotate which pane each task is executed in (editor / agent / files)
```

### SpecKit Directory Structure

```
.spe-kit/
  constitution.md            # Project principles (starting point for all requirements)
  specify.md                 # Requirements document
  clarify.md                 # Clarification records
  plan.md                    # Technical design
  tasks.md                   # Task checklist
```

### Layout Initialization: `dev-layout-init`

```fish
# ~/.config/fish/functions/dev-layout-init.fish
function dev-layout-init
    set -l first_pane (cmux list-panes | string match -r -g '.*(pane:[0-9]+).*' | head -1)
    set -l file_surface (cmux list-pane-surfaces --pane $first_pane | string match -r -g '.*(surface:[0-9]+).*' | head -1)
    cmux rename-tab --surface $file_surface file

    set -l editor_surface (cmux new-split right | string match -r -g '.*(surface:[0-9]+).*')
    cmux rename-tab --surface $editor_surface editor

    set -l agent_surface (cmux new-split down | string match -r -g '.*(surface:[0-9]+).*')
    cmux rename-tab --surface $agent_surface agent

    cmux focus-pane --pane $first_pane
    echo "3-pane layout created. Please manually start tools in each pane."
end
```

### SOP Full Lifecycle (5 Steps)

```
dev init                            [agent pane] Step 1: spec tool init + 3-pane layout
    ↓
dev specify <name>                  [agent pane] Step 2: wt new + layout + explore + proposal
    ↓                            (OpenSpec: /opsx:explore → /opsx:propose)
    ↓                            (SpecKit: specify specify → clarify)
dev plan                            [agent pane] Step 3: plan + tasks + review-doc + commit
    ↓                            (AI review spec docs → commit, no push)
dev implement                       [agent pane] Step 4: apply + review-code + commit
    ↓                            (AI review code diff → commit, no push)
    ↓                            (OpenSpec: /opsx:apply)
    ↓                            (SpecKit: specify implement)
dev archive                         [agent pane] Step 5: archive + push + close + remove
                                 (OpenSpec: /opsx:archive → push → close workspace → wt remove)
                                 (SpecKit: push → close workspace → wt remove)
```

> **Note**: Commits occur at Step 3 (post review-doc) and Step 4 (post review-code), but push only happens at Step 5 (archive).

---

## cmux hooks — Claude Behavior Rules

Report status via cmux automatically during task execution. All command names verified against cmux API.

When starting a sub-task:
```bash
cmux set-progress 0.3 --label "Analyzing code..."
cmux set-status "task" "Analyzing code" --icon "hammer"
```

When code modification is complete:
```bash
cmux set-progress 0.7 --label "Modification complete, awaiting review"
cmux set-status "task" "Modification complete" --icon "pencil"
```

When finished:
```bash
cmux set-progress 1.0 --label "Complete"
cmux set-status "task" "done" --icon "checkmark.circle" --color "#00CC66"
cmux notify --title "claude" --body "Task complete, please review"
```

When executing openspec commands, sync the workspace stage:
```bash
# /opsx:propose
cmux set-status stage plan --icon list.clipboard
# /opsx:apply
cmux set-status stage implement --icon hammer
# /opsx:archive
cmux set-status stage archive --icon archivebox
```

> **Note**: cmux does not have a `new-surface` CLI command. If the Agent needs parallel sub-tasks, use ⌘T (manually) to create a new surface within a pane or execute sequentially in the current surface.

---

## Status Perception Mechanism

### Dual-Layer Perception: cmux Macro + Starship Micro

```
                    ┌─────────────────────────────────┐
                    │       cmux sidebar (Macro)        │
                    │  · Workspace list / Notifications │
                    │  · Agent progress bar 0.0 → 1.0   │
                    │  · Status pills (Task + Icon)     │
                    │  · System notifications           │
                    └─────────────────────────────────┘
                              ↕ Complementary
                    ┌─────────────────────────────────┐
                    │     Starship prompt (Micro)       │
                    │  · Current git branch             │
                    │  · dirty / staged / ahead/behind  │
                    │  · Language runtime version       │
                    │  · Directory visual identity      │
                    └─────────────────────────────────┘
```

Perceive context via the prompt without switching panes; perceive global progress via the sidebar without switching workspaces.

### cmux Sidebar + Notifications

| Mechanism | Description |
|-----------|-------------|
| Sidebar Workspace Tab | Shows workspace list, current workspace highlighted |
| Notification Ring | Blue ring on workspace tab when task is complete |
| Progress Bar | Agent reports 0.0 → 1.0 via `cmux set-progress` |
| Status Pill | Agent shows current sub-task and icon via `cmux set-status` |
| System Notification | `cmux notify` triggers macOS Notification Center |

### Native cmux Shortcuts

```
⌘⇧N         New Window
⌘D          Split pane right
⌘⇧D         Split pane down
⌥⌘ + Arrows  Navigate between panes
⌘T          New surface (tab within pane)
⌘[ / ⌘]     Switch between surfaces
⌘1-⌘9       Switch surface by tab number
⌃1-⌃9       Switch workspace by tab number
⌘⇧P         Command Palette (Search all actions)
```

---

## Tool Interoperability

### User Habits: Emacs-Style Cursor Control

Ctrl+A/E/B/F/N/P work across the stack without conflict. Helix insert mode is configured in `helix/.config/helix/config.toml`. Fish / claude / cmux / Yazi / LazyGit support these natively or do not use these combinations.

### Integration Key Points

Interactions already defined in configuration files:

| Integration | Config File | Effect |
|-------------|-------------|--------|
| Yazi → Helix | `yazi/.config/yazi/keymap.toml` | Press `e` to open file in Helix |
| Helix → LazyGit | `helix/.config/helix/config.toml` | `Ctrl+G` to open LazyGit |
| LazyGit → Helix | `lazygit/.config/lazygit/config.yml` | Press `e` to open diff in Helix |
| Fish Environment | `fish/.config/fish/config.fish` | EDITOR/GIT_EDITOR/VISUAL all point to hx |
| Starship prompt | `starship/.config/starship.toml` | git branch + dirty flag + language env |
| worktrunk Path | `worktrunk/.config/worktrunk/config.toml` | `../<project>-<branch>` template |
| Stow Deployment | dotfiles package | Unified management of symlinks in HOME |

---

## Parallel Development

Leverage worktrunk + cmux workspace + OpenSpec for multi-threaded development:

```bash
# Open 3 worktrees simultaneously, each auto-creating cmux workspace + 3-pane layout
dev wt new feature/login
dev wt new feature/payment
dev wt new fix/api-crash

# Run OpenSpec processes independently in each workspace's agent pane
# workspace 1: /opsx:propose "Implement login system"
# workspace 2: /opsx:propose "Implement payment module"
# workspace 3: /opsx:propose "Fix API crash"

# Each agent executes /opsx:apply independently, reporting progress via cmux hooks.
# You only monitor the sidebar notification rings and switch to review when done.
```
