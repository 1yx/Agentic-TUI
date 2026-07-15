function __devflow_log --description 'Verbose debug line for devflow (stderr)'
    # Only prints when devflow was invoked with --verbose/-v, which sets the
    # global __DEVFLOW_VERBOSE. Routed to stderr so it never pollutes the
    # stdout summary (and sidesteps the stdout buffering that hides echo
    # output while a child command runs).
    if set -q __DEVFLOW_VERBOSE
        echo (set_color brblack)"  · $argv"(set_color normal) >&2
    end
end
