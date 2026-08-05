# codex/ — OpenAI Codex 配置(stow 包)

本包通过 GNU Stow 管理 `~/.codex/` 下的两个文件:

| 文件 | 作用 | 含密钥? |
|---|---|---|
| `models.json` | DeepSeek 模型元数据声明(context window、reasoning levels、tool types 等),让 Codex 把 `deepseek-v4-flash` 当已知模型而非 fallback | 否 |
| `deepseek.config.toml` | Codex profile,`codex --profile deepseek` 时叠加在 `config.toml` 之上 | 否(key 在 base config.toml) |

## 为什么 `~/.codex/config.toml` 不被本包管理

`config.toml` 是 Codex 主配置,但塞满了**不适合跨机器同步 / 进 git** 的内容:

- **明文 API key** —— `[model_providers.deepseek].experimental_bearer_token` 直接存 DeepSeek key
- **机器特定路径** —— `notify` 指向本机 `Codex.app`、`mcp_servers.*` 的可执行路径(如 `/Applications/Codex.app/...`)
- **运行时状态** —— `[projects.*]` 的 trust_level、`[marketplaces.*]` 缓存时间戳、`[tui.model_availability_nux]` 计数、`[notice]` 标志、`[features]` 开关
- **ChatGPT 订阅登录态** —— 与本机账号绑定

这些每台机器不同、且含密钥,因此 `config.toml` 保持为**本机真实文件**,手动维护;只有纯净的 `models.json` 和 profile 进 stow。

## 如何引入(新机器上)

### 1. 部署本 stow 包(管 models.json + profile)

```bash
./install.sh --apply
# 产出:~/.codex/models.json 和 ~/.codex/deepseek.config.toml 两个 symlink
```

> 若 `~/.codex/` 下已存在同名真实文件,stow 会报冲突。先 `bash backup_configs.sh` 备份并清除,再 `--apply`。

### 2. 手动编辑 `~/.codex/config.toml`(追加,不改现有内容)

**顶层**(第一个 `[section]` 之前)加一行,让 Codex 加载 model catalog:

```toml
model_catalog_json = "~/.codex/models.json"
```

**文件末尾**追加 DeepSeek provider 块(这里才放 key):

```toml
[model_providers.deepseek]
name = "deepseek"
base_url = "https://api.deepseek.com/"
wire_api = "responses"
experimental_bearer_token = "<你的 DeepSeek API Key>"
```

> `model_catalog_json` 是全局顶层键 —— 它 union 进 effective catalog,不会污染 GPT-5.6 的元数据(两者按 slug 隔离)。默认 `model = "gpt-5.6-terra"` 保持不变。

### 3. 使用

```bash
codex                    # 默认 GPT,ChatGPT 订阅登录
codex --profile deepseek # 切到 deepseek-v4-flash(provider 自带 token 鉴权),reasoning=high
```

`--profile deepseek` 切换 model + provider + reasoning effort。**鉴权不切** —— DeepSeek 靠 provider 的 `experimental_bearer_token` 自带鉴权,与 ChatGPT 订阅登录态互不干扰(设 `preferred_auth_method`/`forced_login_method` 会触发「Logging out」登出 ChatGPT)。

## 验证

```bash
codex --profile deepseek
```

启动 banner 显示 `model: deepseek-v4-flash` 即成功。若日志出现 `fallback model metadata` 或 `Unknown model`,说明 `models.json` 未被加载 —— 检查 `model_catalog_json` 路径是否正确。

## 切回 GPT

直接 `codex`(不带 `--profile`)。`config.toml` 顶层 `model` 从未被改,GPT 基线零影响。

## 事实来源

- `models.json` —— 提取自 DeepSeek 官方安装脚本 `codex-deepseek-setup-en.sh`(https://api-docs.deepseek.com/quick_start/agent_integrations/codex ),DeepSeek 官方验证过的模型声明,勿手动修改。
- `deepseek.config.toml` —— 手写,可自由调整 reasoning effort 等。
