function __cld_launch --description 'Launch claude with GNU toolchain PATH prepended'
    # Build gnubin-prefixed PATH for AI Agent GNU compatibility
    set -l brew_prefix (brew --prefix)
    set -l gnu_paths
    for pkg in coreutils gnu-sed findutils gawk gnu-tar grep ed gpatch
        set -l gnubin "$brew_prefix/opt/$pkg/libexec/gnubin"
        if test -d "$gnubin"
            set -a gnu_paths "$gnubin"
        end
    end
    set -l target_path (string join ":" $gnu_paths $PATH)
    env PATH="$target_path" command claude $argv
end

function cld --argument provider
    # If no provider or starts with '-', use CLD_DEFAULT_PROVIDER or pass through to claude
    if test -z "$provider"; or string match -q -- '-*' "$provider"
        if set -q CLD_DEFAULT_PROVIDER
            cld $CLD_DEFAULT_PROVIDER $argv
        else
            __cld_launch $argv
        end
        return
    end

    set -l env_args

    switch "$provider"
        case proxy
            set -a env_args ANTHROPIC_BASE_URL=$CLD_PROXY_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_PROXY_TOKEN
        case glm
            set -a env_args ANTHROPIC_BASE_URL=$CLD_GLM_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_GLM_TOKEN
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-5.2
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2
            # Kimi uses ANTHROPIC_API_KEY per official docs:
            # https://www.kimi.com/code/docs/third-party-tools/other-coding-agents.html
        case kimi
            set -a env_args ANTHROPIC_BASE_URL=$CLD_KIMI_URL
            set -a env_args ANTHROPIC_API_KEY=$CLD_KIMI_KEY
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-for-coding
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-for-coding
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-for-coding
        case qwen
            set -a env_args ANTHROPIC_BASE_URL=$CLD_OPENROUTER_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_OPENROUTER_TOKEN
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=qwen/qwen3.6-plus:free
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=qwen/qwen3.6-plus:free
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=qwen/qwen3.6-plus:free
        case minimax
            set -a env_args ANTHROPIC_BASE_URL=$CLD_OPENROUTER_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_OPENROUTER_TOKEN
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=minimax/minimax-m2.5:free
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=minimax/minimax-m2.5:free
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=minimax/minimax-m2.5:free
        case ds
            set -a env_args ANTHROPIC_BASE_URL=$CLD_DS_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_DS_KEY
            set -a env_args ANTHROPIC_MODEL=deepseek-v4-pro[1m]
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
            set -a env_args CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
            set -a env_args CLAUDE_CODE_EFFORT_LEVEL=max
        case xm
            set -a env_args ANTHROPIC_BASE_URL=$CLD_XM_URL
            set -a env_args ANTHROPIC_AUTH_TOKEN=$CLD_XM_KEY
            set -a env_args ANTHROPIC_MODEL=mimo-v2.5-pro
            set -a env_args ANTHROPIC_DEFAULT_SONNET_MODEL=mimo-v2.5-pro
            set -a env_args ANTHROPIC_DEFAULT_OPUS_MODEL=mimo-v2.5-pro
            set -a env_args ANTHROPIC_DEFAULT_HAIKU_MODEL=mimo-v2.5-pro
        case '*'
            echo "Usage: cld <proxy|glm|kimi|qwen|minimax|ds|xm> [claude args...]"
            echo "       cld [claude args...]  (uses \$CLD_DEFAULT_PROVIDER)"
            return 1
    end
    set -e argv[1]

    # Build gnubin-prefixed PATH for AI Agent GNU compatibility
    set -l brew_prefix (brew --prefix)
    set -l gnu_paths
    for pkg in coreutils gnu-sed findutils gawk gnu-tar grep ed gpatch
        set -l gnubin "$brew_prefix/opt/$pkg/libexec/gnubin"
        if test -d "$gnubin"
            set -a gnu_paths "$gnubin"
        end
    end
    set -l target_path (string join ":" $gnu_paths $PATH)
    env $env_args PATH="$target_path" command claude $argv
end
