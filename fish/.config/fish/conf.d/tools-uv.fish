# uv (Python package manager)
if status --is-interactive; and command -v uv >/dev/null 2>&1
    set -gx UV_MANAGED_PYTHON 1
end
