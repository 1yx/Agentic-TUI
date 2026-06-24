# TTY 驱动、Readline 与 Keymap 的关系

终端按键处理分为三层，从底层到上层：

```
ASCII（ISO 646）       — 控制字符编码（Ctrl+字母 → 字节）
    ↓
TTY 驱动（POSIX）      — stty / termios，拦截部分字节并执行信号/编辑操作
    ↓
应用层                 — fish / helix / claude code 等自行处理按键
```

其中按键从键盘到应用的完整路径：

```
Ghostty（终端模拟器）   — 捕获键盘事件，将按键转为字节写入 PTY master
    ↓
TTY 驱动（内核）        — PTY slave 侧，按 termios 设置拦截或放行字节
    ↓
应用程序（Fish 等）     — raw 模式下自行处理全部按键
```

## 1. TTY 与 Terminal 的关系

**TTY** = TeleTYpewriter，最早指物理的电传打字机（带键盘 and 打印头的机械设备），通过串口线连到计算机。

**Terminal** = 终端，是 TTY 的后续概念。早期终端也是硬件（如 DEC VT100），替代了电传打字机，用屏幕代替了纸。

### 硬件演进

```
1960s  电传打字机（物理 TTY）  — 键盘 + 打印头，串口连接
1970s  视频终端（如 VT100）    — 键盘 + CRT 屏幕，串口连接
1980s  终端模拟器（xterm 等）  — 软件模拟 VT100，PTY 连接
2020s  Ghostty / Kitty / Alacritty — 现代 GPU 终端模拟器，PTY 连接
```

内核里的 TTY 驱动和 PTY（pseudo-TTY）接口就是当年为物理电传打字机设计的，一直沿用至今。现在 Ghostty 就是"模拟的那台打字机"，PTY 就是"那根串口线"，TTY 驱动就是"内核里处理串口数据的那个模块"。

### 名称遗留

| 名称 | 本意 | 现在的含义 |
|---|---|---|
| TTY | 电传打字机 | 内核的终端驱动模块 |
| PTY | 伪电传打字机 | 软件模拟的 TTY（master/slave 对） |
| terminal | 物理终端设备 | 终端模拟器软件（Ghostty） |
| console | 系统控制台（直接连的终端） | 通常指 TUI 或系统主终端 |
| `stty` | set teletype | 配置 TTY 驱动参数 |
| `/dev/tty` | TTY 设备文件 | 当前终端的设备文件 |

## 2. ASCII 控制字符编码规则

```
Ctrl + 字母 = ASCII 码 - 64（即屏蔽第 6、7 位）
```

| 按键 | 计算 | 字节 | ASCII 名称 | 含义 |
|---|---|---|---|---|
| `Ctrl+M` | M(77) - 64 = 13 | `0x0D` | CR | 等同于 Enter |
| `Ctrl+J` | J(74) - 64 = 10 | `0x0A` | LF | line feed |
| `Ctrl+I` | I(73) - 64 = 9 | `0x09` | HT | 等同于 Tab |
| `Ctrl+[` | [(91) - 64 = 27 | `0x1B` | ESC | escape |
| `Ctrl+C` | C(67) - 64 = 3 | `0x03` | ETX | end of text |
| `Ctrl+D` | D(68) - 64 = 4 | `0x04` | EOT | end of transmission |

这是 1960 年代 ASCII 标准定义的编码规则。`Ctrl+M = Enter`、`Ctrl+I = Tab` 不是工具的设定，而是字节层面就是同一个值。

## 3. TTY 驱动（termios）

TTY 驱动是内核中的一层软件，介于终端和进程之间。POSIX（IEEE 1003.1 / ISO/IEC 9945）通过 `termios` 结构体定义了这层的行为：

```c
struct termios {
    tcflag_t c_iflag;    // 输入模式标志
    tcflag_t c_oflag;    // 输出模式标志
    tcflag_t c_cflag;    // 控制模式标志
    tcflag_t c_lflag;    // 本地模式标志 (echo, icanon ...)
    cc_t     c_cc[NCCS]; // 特殊字符数组
};
```

### `c_cc` 数组（Linux，共 19 项）

| 下标 | stty 名称 | 默认 | 含义 |
|---|---|---|---|
| VINTR | `intr` | `^C` | 发 SIGINT |
| VQUIT | `quit` | `^\` | 发 SIGQUIT |
| VERASE | `erase` | `^?` | 删前一字符 |
| VKILL | `kill` | `^U` | 删整行 |
| VEOF | `eof` | `^D` | EOF 标记 |
| VSTART | `start` | `^Q` | 恢复输出（XON） |
| VSTOP | `stop` | `^S` | 暂停输出（XOFF） |
| VSUSP | `susp` | `^Z` | 发 SIGTSTP |
| VEOL | `eol` | `<undef>` | 行结束符 |
| VEOL2 | `eol2` | `<undef>` | 备用行结束符 |
| VREPRINT | `rprnt` | `^R` | 重显未完成的行 |
| VWERASE | `werase` | `^W` | 删前一词 |
| VLNEXT | `lnext` | `^V` | 字面引用下一字符 |
| VDISCARD | `discard` | `^O` | 切换输出丢弃 |
| VMIN | `min` | `1` | read() 最少返回字符数 |
| VTIME | `time` | `0` | read() 超时（0.1 秒单位） |
| VSWTC | — | `\0` | Switch（System V 遗留，Linux 未使用） |

> `VMIN` 和 `VTIME` 不是字符，是控制 `read()` 阻塞行为的数值参数，复用了 `c_cc` 数组的下标位置。
> macOS/BSD 略有不同，有 `VDSUSP`（延迟 suspend）等，没有 `VSWTC`。

### stty

`stty`（set teletype）是用户侧配置工具，底层操作 `tcgetattr()`/`tcsetattr()` 读写 `termios` 结构体：

```
stty -a
intr = ^C     →  SIGINT（中断）
quit = ^\     →  SIGQUIT（退出 + core dump）
susp = ^Z     →  SIGTSTP（挂起）
erase = ^?    →  删除前一字符（传统 Unix/Linux TTY 默认为 ^H）
kill = ^U     →  删除整行
eof = ^D      →  EOF 标记
```

## 4. icanon 模式：为电传打字机设计的行编辑

`icanon`（canonical 模式）是 TTY 驱动的默认行编辑模式——TTY 驱动替用户维护一行输入缓冲区，按 Enter 后才整行交给应用程序。这个设计完全是为了适配电传打字机"输入无法撤回"的物理限制。

电传打字机在纸上打字，没有光标，不能回到前面修改。编辑只能在 TTY 驱动的内部缓冲区里做，纸上只能看到涂改痕迹：

| 按键 | TTY 缓冲区操作 | 纸上的效果 |
|---|---|---|
| `^?` (erase) | 删末字符 | 回退一格，打印 `#` 覆盖，表示作废 |
| `^W` (werase) | 删末词 | 逐字覆盖 |
| `^U` (kill) | 清空整行 | 打印 `@` 表示整行作废，换行重打 |
| `^R` (reprint) | 重新输出缓冲区内容 | 把当前有效内容重打一遍 |

操作者输入序列：`fix the bu` + `^W` + `^W` + `the bug`

纸上（操作者看到的，带涂改）：

```
fix the bu####the bug
         ^^^^
         两个 ^W 的涂改标记，覆盖了 bu 和 the
```

TTY 缓冲区（操作者看不到，逐步演变）：

```
fix the bu
         ↑ 输入到这里
fix the
       ↑ ^W 删掉 bu
fix
   ↑ ^W 删掉 the
fix the bug
           ↑ 接着输入 the bug
```

纸上看到的是带涂改的完整历史，缓冲区在每一步都是干净的状态。

这里有一个关键区别：

- **纸** = 显示（不可擦除，只能划掉覆盖）
- **TTY 缓冲区** = 数据（可以自由修改，用户看不到）

操作者看到的纸和 TTY 持有的缓冲区是**不同步的**。纸上是带涂改痕迹的历史，缓冲区是干净的真实内容。`^R`（reprint）就是为了解决这个问题——操作者忘了缓冲区里到底是什么，按 `^R` 让 TTY 把缓冲区的干净内容重新打一遍到纸上，相当于"刷新显示"。

到了视频终端（VT100），有了光标和屏幕擦除能力，TTY 驱动就可以在 `erase` 时发 `BS SPACE BS` 序列来真正擦掉屏幕上的字符，纸和缓冲区才变得视觉上同步。现代终端模拟器（Ghostty）沿用的就是这个机制。

## 5. TTY 拦截 vs 应用处理

TTY 驱动拦截到的字节就自行处理（发信号、编辑行），没拦截的才传给上层应用。

```
键盘 Ctrl+C → 0x03 → TTY 拦截 → SIGINT → 进程收到信号
键盘 Ctrl+A → 0x01 → TTY 不拦截 → 传给 readline/fish → 应用处理
```

因此：

- `Ctrl+C`（SIGINT）、`Ctrl+Z`（SIGTSTP）、`Ctrl+\`（SIGQUIT）—— TTY 层处理
- `Ctrl+A`（行首）、`Ctrl+E`（行尾）、`Ctrl+K`（删到行尾）—— readline / 应用层处理
- `Ctrl+U` / `Ctrl+W` / `Ctrl+D` —— TTY 的 icanon 模式下由 TTY 处理。但在应用层（如 Readline）接管后，`Ctrl+U` 通常被重新定义为"删至行首"而非"删整行"。

## 6. Readline 与 POSIX 的关系

Readline 不是规范，是 **GNU Readline**——1988 年 Brian Fox 为 GNU Project 编写的行编辑库。它的按键绑定来自 Emacs 惯例，不是来自标准。

### 历史脉络

```
1970s  Unix sh
       编辑能力 = termios cooked 模式（^U 删行, ^W 删词, ^? 退格）
       仅此而已，没有光标移动

1978   BSD csh
       Bill Joy 引入了命令历史替换（!!, !$），但仍无交互式行编辑

1983   tcsh / ksh
       正式引入 emacs-mode / vi-mode 交互式行编辑
       首次实现 Ctrl+A 行首、Ctrl+E 行尾等光标移动

1988   GNU Readline
       Brian Fox 为 bash 创建的可复用行编辑库
       沿用 tcsh/ksh 的 Emacs 按键惯例（Ctrl+A/E/B/F/N/P...）
       作为独立库供 bash、gdb、python REPL、psql 等使用

1990s  POSIX（IEEE 1003.1 / ISO 9945）
       标准化了 termios 接口（icanon, c_cc 数组）
       标准化了 sh 的命令语言语法
       但没有标准化行编辑的具体按键绑定
       POSIX 只要求 sh 支持 canonical 模式下的基本编辑（erase/kill）
```

### 标准化层级

```
POSIX termios       — 规范化了 TTY 驱动行为（已标准化）
    ↑ 不被标准化覆盖 ↑
BSD tcsh / GNU Readline — 行编辑的按键绑定（事实标准，非正式规范）
    ↑ 各自实现 ↑
Fish / Helix / Claude Code — 不使用 GNU Readline，自行实现行编辑
```

### 关键点

- **POSIX 没有定义** `Ctrl+A` = 行首、`Ctrl+E` = 行尾这类按键绑定。POSIX 只规定了 `c_cc` 中 `VERASE`、`VKILL`、`VWERASE` 等字符的语义
- **Emacs 按键惯例是事实标准**，通过 tcsh/ksh → GNU Readline → bash 传播开来，不是任何规范定义的
- **Fish 不用 GNU Readline**，自己实现了行编辑，但沿用同样的 Emacs 按键（`Ctrl+A/E/B/F/N/P`），因为是肌肉记忆层面的约定
- **Helix、Claude Code 同理**，各自实现输入处理，遵循 Emacs 惯例而非某个规范

keymap.md 中 Global 表里的快捷键，本质上是 40 年来由 Emacs → tcsh → GNU Readline 传播下来的**惯例**，不是某个 ISO/POSIX 规范的产物。

## 7. Raw 模式与应用程序行为

### Cooked 模式 vs Raw 模式

Raw 模式是 termios 的一个配置状态，关闭所有 TTY 驱动的处理，让应用程序直接拿到原始字节。对应的 **cooked 模式**（也叫 canonical 模式）是 TTY 驱动开启全部处理的默认状态：

| 行为 | Cooked 模式（默认） | Raw 模式 |
|---|---|---|
| 行缓冲 | 输入在按 Enter 后才传给应用 | 每个字节立刻传给应用 |
| `^C` → SIGINT | TTY 拦截并发信号 | 字节 `0x03` 直接传给应用 |
| `^U` / `^W` | TTY 执行删行/删词 | 字节直接传给应用 |
| `^D` EOF | TTY 触发 EOF | 字节 `0x04` 直接传给应用 |
| `^S` / `^Q` | TTY 暂停/恢复输出 | 字节直接传给应用 |
| 回显 | TTY 自动回显输入 | 应用自己决定是否回显 |
| `^V` | TTY 转义下一个字符 | 字节直接传给应用 |

POSIX 提供 `cfmakeraw()` 函数，一步把 termios 设为 raw 模式，本质上就是批量关闭 `icanon`、`echo`、`ISIG`、`IXON` 等标志位。

### 三个角色

```
Ghostty（终端模拟器）   — 捕获键盘事件，将按键转为字节写入 PTY master
    ↓
TTY 驱动（内核）        — PTY slave 侧，按 termios 设置拦截或放行字节
    ↓
Fish / Helix / Claude Code（应用程序）— 调用 tcsetattr() 切换 raw 模式，自行处理按键
```

Ghostty 不参与 raw 模式切换，它只负责把键盘事件变成字节发给 PTY。是 Fish、Helix、Claude Code 这些应用程序调用 `tcsetattr()` 修改 termios 标志，关闭 `icanon`、`ISIG` 等，接管按键处理。

这意味着 `c_cc` 中定义的大部分行为被绕过，应用自行决定每个按键的含义。

### 与 keymap.md 的重叠

| TTY `c_cc` | TTY 行为 | keymap.md | 工具行为 | 冲突？ |
|---|---|---|---|---|
| `^C` | SIGINT | Fish `Ctrl+C` cancel | 同义，工具保留 TTY 处理 | 无 |
| `^D` | VEOF（退出） | Fish `Ctrl+D` exit | 同义 | 无 |
| `^U` | VKILL（删整行） | Global `Ctrl+U` delete to line start | 语义微调：TTY 删整行，应用删至行首 | 无 |
| `^W` | VWERASE（删前一词） | Global `Ctrl+W` delete previous word | 同义，raw 模式下应用处理 | 无 |
| `^S` | VSTOP（暂停输出） | Helix `Ctrl+S` save / Claude Code `ctrl+s` stash | raw 模式下 `IXON` 被关闭，不拦截 | 无 |
| `^R` | VREPRINT | Claude Code `ctrl+r` history:search | raw 模式下应用处理 | 无 |

**结论：无实际冲突。** 工具在 raw 模式下接管了所有按键，`c_cc` 中的定义不再生效。工具的按键绑定与 TTY 默认行为语义一致，是刻意为之。

## 8. Ctrl+J vs Ctrl+M

两者在终端行为上的区别：

| 按键 | 字节 | 终端默认行为 | 可否绑定 |
|---|---|---|---|
| `Ctrl+M` | `0x0D` (CR) | 等同于 Enter | 不可，字节相同 |
| `Ctrl+J` | `0x0A` (LF) | 不同于 Enter | 可以，字节不同 |

在 **Cooked 模式**下，TTY 驱动默认开启 `icrnl` (Input CR to NL) 标志位，将输入的 `0x0D` (CR) 自动转为 `0x0A` (LF)。这意味着在应用层看来，`Ctrl+M` 和 `Ctrl+J` 拿到的字节都是 `0x0A`，无法区分。

在 Claude Code 等工具进入 **Raw 模式**后，`icrnl` 被关闭，`Ctrl+M` (0x0D) 和 `Ctrl+J` (0x0A) 的原始字节被应用直接获取，从而实现了独立绑定。例如 `Shift+Enter` 在 Ghostty 中被映射到 `Ctrl+J`：

```json
{
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+j": "chat:newline"
      }
    }
  ]
}
```

这利用了 `Ctrl+J`（LF）和 `Enter`（CR）在字节层面的差异，只有在接管了 TTY 设置的应用中才能发挥作用。
