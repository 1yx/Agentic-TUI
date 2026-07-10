# Agentic-TUI CHECKSHEET

Single-page shortcut sheet for this repo.

Rule:

- repo config wins over tool defaults
- read `AGENTS.md` before changing shortcuts
- in this setup, macOS `Option` is sent as `Alt` via Ghostty

## Global

| Key | Meaning |
|---|---|
| `Ctrl+A` | line start |
| `Ctrl+E` | line end |
| `Ctrl+B` | left |
| `Ctrl+F` | right |
| `Ctrl+N` | down / next |
| `Ctrl+P` | up / previous |
| `Ctrl+U` | delete to line start |
| `Ctrl+K` | delete to line end |
| `Ctrl+W` | delete previous word |
| `Ctrl+J` | insert newline |
| `Alt+B` | move backward by word |
| `Alt+F` | move forward by word |
| `Alt+D` | delete next word |

## cmux

| Key | Meaning |
|---|---|
| `Cmd+N` | new workspace |
| `Cmd+Shift+N` | new window |
| `Cmd+D` | split right |
| `Cmd+Shift+D` | split down |
| `Cmd+T` | new surface/tab |
| `Cmd+Shift+[` | previous tab |
| `Cmd+Shift+]` | next tab |
| `Cmd+1..8` | go to surface |
| `Cmd+9` | last surface |
| `Ctrl+1..8` | go to workspace |
| `Ctrl+9` | last workspace |
| `Cmd+[` | previous split |
| `Cmd+]` | next split |
| `Option+Cmd+Arrows` | move between panes |
| `Cmd+Ctrl+Arrows` | resize pane |
| `Cmd+Ctrl+=` | equalize panes |
| `Cmd+Shift+P` | command palette |
| `Cmd+W` | close surface |

## Ghostty

| Key | Meaning |
|---|---|
| `Cmd+,` | open config |
| `Cmd+Shift+,` | reload config |
| `Cmd+C` / `Cmd+V` | copy / paste |
| `Cmd+=` `Cmd+-` `Cmd+0` | font in / out / reset |
| `Cmd+N` | new window |
| `Cmd+T` | new tab |
| `Cmd+W` | close surface |
| `Cmd+Shift+W` | close window |
| `Cmd+Enter` | fullscreen |
| `Cmd+Shift+P` | command palette |
| `Cmd+F` | search |
| `Esc` | end search |

## Fish

Defaults still in use:

| Key | Meaning |
|---|---|
| `Tab` | complete |
| `Enter` | execute |
| `Ctrl+C` | cancel |
| `Ctrl+D` | exit |
| `Ctrl+B / Ctrl+F` | move left / right |

Repo commands:

| Command | Meaning |
|---|---|
| `yy` | open Yazi and cd back to final dir |
| `e` | open `emacsclient` |
| `timeout` | `gtimeout` |


## Helix

Start here:

- `hx --tutor`
- official keymap: https://docs.helix-editor.com/keymap.html

Repo custom:

| Key | Meaning |
|---|---|
| `Ctrl+G` | open `lazygit` |
| `Ctrl+S` | save |
| `Ctrl+A/E/B/F/N/P` | Emacs-style insert mode movement |
| `Ctrl+K / Ctrl+U` | delete to line end / start in insert mode |
| `Ctrl+W` | delete previous word in insert mode |
| `Alt+B / Alt+F` | previous / next word in insert mode |
| `Alt+D` | delete next word in insert mode |

Normal mode: movement

| Key | Meaning |
|---|---|
| `h j k l` | left / down / up / right |
| `w` / `b` / `e` | next word / previous word / word end |
| `f<char>` | find character |
| `t<char>` | move to character |
| `Home` / `End` | line start / line end |
| `gg` / `ge` | file start / file end |
| `Ctrl+b` / `Ctrl+f` | page up / page down |
| `Ctrl+u` / `Ctrl+d` | half page up / down |

Normal mode: editing

| Key | Meaning |
|---|---|
| `i` / `a` | insert before / after |
| `I` / `A` | insert at line start / end |
| `o` / `O` | open line below / above |
| `r` | replace with one character |
| `R` | replace with yanked text |
| `~` | switch case |
| `` ` `` / `Alt+\`` | lowercase / uppercase |
| `d` / `c` | delete / change selection |
| `Alt+d` / `Alt+c` | delete / change without yanking |
| `y` | yank selection |
| `p` / `P` | paste after / before |
| `>` / `<` | indent / unindent |
| `=` | format selection |
| `u` / `U` | undo / redo |
| `Alt+u` / `Alt+U` | earlier / later history state |
| `.` | repeat last insert |
| `Ctrl+a` / `Ctrl+x` | increment / decrement number |
| `Q` / `q` | record / replay macro |

Normal mode: selection manipulation

| Key | Meaning |
|---|---|
| `v` | select mode |
| `x` | select current line |
| `X` / `Alt+x` | grow / shrink to line bounds |
| `%` | select entire file |
| `;` | collapse selection to cursor |
| `Alt+;` | flip cursor and anchor |
| `Alt+:` | ensure selections are forward |
| `J` / `Alt+J` | join lines / join and select inserted space |
| `_` | trim whitespace from selection |

Normal mode: multiple selections

Multiple selections are core to Helix: hold any number of cursors/selections at once, and nearly every command (edit, indent, comment, `y`, `Space y`) applies to all of them in parallel.

Create multiple selections:

| Key | Meaning |
|---|---|
| `s` | select all regex matches inside selection |
| `S` | split selection into sub-selections on regex |
| `Alt+s` | split selection on newlines (one selection per line) |
| `C` / `Alt+C` | copy selection onto next / previous line (add cursor) |

> Search builds them too: `/` then `v` enters select mode, after which `n` / `N` accumulate each match as a new selection instead of replacing. Tree-sitter siblings (`Alt+a` / `Alt+n` / `Alt+p`) also create multiple selections — see Tree-sitter below.

Manage multiple selections:

| Key | Meaning |
|---|---|
| `,` / `Alt+,` | keep only primary / remove primary selection |
| `Alt+-` / `Alt+_` | merge selections / merge consecutive selections |
| `(` / `)` | rotate main selection backward / forward |
| `Alt+(` / `Alt+)` | rotate selection contents backward / forward |
| `&` | align selections in columns |
| `K` / `Alt+K` | keep / remove selections matching regex |
| `Ctrl+c` | toggle comments (all selections) |

Typical workflows:

- rename all occurrences in a line: `x` select line → `s` type word → `c` change → `Esc`
- column edit: press `C` repeatedly to add cursors downward, then `i` to insert
- copy many selections to clipboard: select them, then `Space y` joins all with newlines into the system clipboard

Normal mode: search and commands

| Key | Meaning |
|---|---|
| `/` | search |
| `n` / `N` | next / previous match |
| `*` | select current word |
| `:` | command prompt |
| `Space` | space menu |
| `Space f` | file picker |
| `Space b` | buffer picker |
| `Space /` | global search |
| `Esc` | back to normal mode / cancel |

Normal mode: goto mode

| Key | Meaning |
|---|---|
| `g` | enter goto mode |
| `g g` | file start |
| `g e` | file end |
| `g n` / `g p` | next / previous buffer |
| `g a` | alternate file |
| `g m` | last modified file |
| `g .` | last modification in file |
| `g j` / `g k` | textual line down / up |
| `g w` | jump to labeled word |

Normal mode: match mode

| Key | Meaning |
|---|---|
| `m` | enter match mode |
| `m m` | matching bracket |
| `m s<char>` | surround selection |
| `m r<from><to>` | replace surround |
| `m d<char>` | delete surround |
| `m a<object>` | select around textobject |
| `m i<object>` | select inside textobject |

Normal mode: tree-sitter and diagnostics

| Key | Meaning |
|---|---|
| `Alt+o` / `Alt+Up` | expand to parent syntax node |
| `Alt+i` / `Alt+Down` | shrink syntax node selection |
| `Alt+p` / `Alt+Left` | previous sibling |
| `Alt+n` / `Alt+Right` | next sibling |
| `Alt+a` | all siblings |
| `Alt+Shift+Down` | all children |
| `Alt+b` / `Alt+e` | parent start / end |
| `[d` / `]d` | previous / next diagnostic |

Insert mode

| Key | Meaning |
|---|---|
| `Esc` | back to normal mode |
| `Ctrl+s` | commit undo checkpoint |
| `Ctrl+x` | autocomplete |
| `Ctrl+r` | insert register content |
| `Ctrl+w` / `Alt+Backspace` | delete previous word |
| `Alt+d` / `Alt+Delete` | delete next word |
| `Ctrl+u` / `Ctrl+k` | delete to line start / end |
| `Ctrl+h` / `Backspace` | delete previous char |
| `Ctrl+d` / `Delete` | delete next char |
| `Ctrl+j` / `Enter` | insert newline |
| `Up/Down/Left/Right` | cursor movement |
| `PageUp/PageDown` | page up / down |
| `Home/End` | line start / end |

Select mode

| Key | Meaning |
|---|---|
| `v` | enter select mode |
| normal-mode motions | extend selection instead of moving cursor |
| `n` / `N` | extend search selections while iterating |
| `Esc` | back to normal mode |

Picker

| Key | Meaning |
|---|---|
| `Tab` / `Down` / `Ctrl+n` | next entry |
| `Shift+Tab` / `Up` / `Ctrl+p` | previous entry |
| `PageUp` / `Ctrl+u` | page up |
| `PageDown` / `Ctrl+d` | page down |
| `Home` / `End` | first / last entry |
| `Enter` | open selected |
| `Alt+Enter` | open in background |
| `Ctrl+s` | open horizontal split |
| `Ctrl+v` | open vertical split |
| `Ctrl+t` | toggle preview |
| `Esc` / `Ctrl+c` | close picker |

Prompt

| Key | Meaning |
|---|---|
| `Esc` / `Ctrl+c` | close prompt |
| `Ctrl+a` / `Home` | prompt start |
| `Ctrl+e` / `End` | prompt end |
| `Ctrl+b` / `Left` | backward char |
| `Ctrl+f` / `Right` | forward char |
| `Alt+b` / `Ctrl+Left` | backward word |
| `Alt+f` / `Ctrl+Right` | forward word |
| `Ctrl+w` / `Alt+Backspace` | delete previous word |
| `Alt+d` / `Ctrl+Delete` | delete next word |
| `Ctrl+u` / `Ctrl+k` | delete to start / end |
| `Backspace` / `Ctrl+h` | delete previous char |
| `Delete` / `Ctrl+d` | delete next char |
| `Ctrl+p` / `Up` | previous history |
| `Ctrl+n` / `Down` | next history |
| `Ctrl+r` | insert register |
| `Tab` / `BackTab` | next / previous completion |
| `Enter` | accept |

## Claude Code

| Key | Meaning |
|---|---|
| `Ctrl+J` | insert newline |

## Gemini CLI

| Key | Meaning |
|---|---|
| `Ctrl+B` | left |
| `Ctrl+K` | delete to line end |

## Pi Agent

Repo custom:

| Key | Meaning |
|---|---|
| `Ctrl+P` | editor cursor up (also keeps `Up`) |
| `Ctrl+N` | editor cursor down (also keeps `Down`) |
| `Ctrl+P` model cycle | disabled |
| `Shift+Ctrl+P` model cycle | disabled |

Defaults worth remembering:

| Key | Meaning |
|---|---|
| `Esc` | cancel / abort |
| `Ctrl+C` | clear editor, copy selection, or cancel selector by context |
| `Ctrl+D` | exit when editor is empty |
| `Shift+Tab` | cycle thinking level |
| `Ctrl+L` | open model selector |
| `Ctrl+O` | toggle tool output |
| `Ctrl+T` | toggle thinking blocks |
| `Ctrl+G` | open external editor |
| `Alt+Enter` | queue follow-up message |
| `Alt+Up` | restore queued messages |
| `Ctrl+V` | paste image from clipboard |
| `Enter` | submit input / confirm selection |
| `Shift+Enter` / `Ctrl+J` | insert newline |
| `Tab` | tab / autocomplete |
| `Ctrl+A` / `Ctrl+E` | line start / end |
| `Ctrl+B` / `Ctrl+F` | left / right |
| `Alt+B` / `Alt+F` | word left / right |
| `Ctrl+W` | delete previous word |
| `Alt+D` | delete next word |
| `Ctrl+U` / `Ctrl+K` | delete to line start / end |
| `Ctrl+-` | undo |
| `Ctrl+Y` / `Alt+Y` | yank / yank pop |

## Yazi

Repo custom:

| Key | Meaning |
|---|---|
| `e` | open file (mdfried for md, Helix otherwise) |
| `E` | open file in Helix |
| `J / K` | scroll preview up / down 1 line |
| `T` | maximize / restore preview pane |

Defaults worth remembering:

| Key | Meaning |
|---|---|
| `q` | quit |
| `F1` or `~` | help |
| `h j k l` | left / down / up / open |
| `g / G` | top / bottom |
| `Space` | select |
| `Enter` | open |
| `/` | search |
| `y x p` | copy / cut / paste |
| `r` | rename |
| `c` | create |
| `d` | delete |

Sort (`[,]` prefix):

| Key | Meaning |
|---|---|
| `[,a` / `[,A` | sort alphabetical / reverse |
| `[,b` / `[,B` | sort by birth time / reverse |
| `[,d` / `[,D` | sort by modified time / reverse |
| `[,e` / `[,E` | sort by extension / reverse |
| `[,n` / `[,N` | sort natural / reverse |
| `[,s` / `[,S` | sort by size / reverse |
| `[,r` | reverse sort order |

Linemode (`m` prefix):

| Key | Meaning |
|---|---|
| `mn` | linemode: none |
| `ms` | linemode: size |
| `mp` | linemode: permissions |
| `mb` | linemode: birth time |
| `mm` | linemode: modified time |
| `mo` | linemode: owner |

## LazyGit

Repo behavior:

| Key | Meaning |
|---|---|
| `e` | open in Helix |

Defaults worth remembering:

| Key | Meaning |
|---|---|
| `q` | back / quit |
| `?` | help |
| `Space` | stage |
| `v` | range select |
| `a` | whole hunk |
| `Enter` | open details |
| `/` | filter |
| `i` | interactive rebase |
| `s f d e` | squash / fixup / drop / edit |
| `Ctrl+J / Ctrl+K` | move rebase entry |
| `Shift+C / Shift+V` | cherry-pick copy / paste |
| `Shift+D` | reset menu |
| `Shift+A` | amend old commit |
| `z / Shift+Z` | undo / redo |
| `w` | create worktree |

## Sources

- local repo config under `fish/`, `helix/`, `yazi/`, `lazygit/`, `ghostty/`
- local runtime output from `ghostty +list-keybinds --default` and `fish -c 'bind --preset'`
- Pi Agent local docs/runtime:
  `pi/.pi/agent/keybindings.json`
  `@earendil-works/pi-coding-agent/docs/keybindings.md`
  `@earendil-works/pi-coding-agent/dist/core/keybindings.js`
- upstream docs:
  https://fishshell.com/docs/4.0/interactive.html
  https://docs.helix-editor.com/keymap.html
  https://yazi-rs.github.io/docs/configuration/keymap
  https://github.com/jesseduffield/lazygit/blob/master/README.md
  https://cmux.com/ru/docs/concepts
