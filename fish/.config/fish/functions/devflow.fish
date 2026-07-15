function devflow --description 'Run a full update across all package managers'
    # One command does the full update: index refresh (e.g. `brew update`)
    # and installation happen in a single pass inside devflow-upgrade.
    # The old read-only `devflow update` was removed — listing outdated
    # packages had no follow-up action since updates are never selective.
    set -e __DEVFLOW_VERBOSE
    set -l cmd

    for arg in $argv
        switch "$arg"
            case --verbose -v
                set -gx __DEVFLOW_VERBOSE 1
            case upgrade update
                set cmd $arg
            case help
                set cmd help
            case '*'
                echo "Unknown argument: $arg" >&2
                echo "Run 'devflow help' for usage." >&2
                return 1
        end
    end

    switch "$cmd"
        case upgrade update ''
            devflow-upgrade
        case help
            echo "Usage: devflow [--verbose|-v] [upgrade|update]"
            echo ""
            echo "Full update across Homebrew, pnpm -g, uv tool, and pi."
            echo "  devflow              full update"
            echo "  devflow upgrade      same (explicit form)"
            echo "  devflow update       alias of upgrade"
            echo "  devflow -v ...       verbose: show swallowed command output,"
            echo "                       parsed outdated lists, and uv raw format"
            echo ""
            echo "Index refresh runs silently as part of the update."
    end
end
