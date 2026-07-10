function devflow --description 'Run a full update across all package managers'
    # One command does the full update: index refresh (e.g. `brew update`)
    # and installation happen in a single pass inside devflow-upgrade.
    # The old read-only `devflow update` was removed — listing outdated
    # packages had no follow-up action since updates are never selective.
    set -l cmd $argv[1]

    switch "$cmd"
        case upgrade update ''
            devflow-upgrade
        case help
            echo "Usage: devflow [upgrade]"
            echo ""
            echo "Full update across Homebrew, pnpm -g, uv tool, and pi."
            echo "  devflow          full update"
            echo "  devflow upgrade  same (explicit form)"
            echo "  devflow update   alias of upgrade"
            echo ""
            echo "Index refresh runs silently as part of the update."
        case '*'
            echo "Unknown command: $cmd"
            echo "Run 'devflow help' for usage."
    end
end
