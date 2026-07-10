function devflow-upgrade --description 'Execute all pending updates'
    set -l start_time (date +%s)
    set -l failures 0
    set -l total_updated 0

    echo ""

    # ── Homebrew ──────────────────────────────────────
    echo (set_color cyan --bold)"  Homebrew"(set_color normal)
    if command -q brew
        # Snapshot outdated before upgrade (greedy to match upgrade behavior)
        brew update >/dev/null
        set -l brew_names
        set -l brew_old
        set -l brew_new
        for entry in (brew outdated --greedy --json=v2 2>/dev/null | jq -r '(.formulae // []) + (.casks // []) | .[] | "\(.name)\t\(.installed_versions[0])\t\(.current_version)"' 2>/dev/null)
            set -l parts (string split \t $entry)
            if test (count $parts) -eq 3
                set -a brew_names $parts[1]
                set -a brew_old $parts[2]
                set -a brew_new $parts[3]
            end
        end
        set -l n (count $brew_names)

        # Keep stderr (brew errors) visible; only swallow stdout so our
        # formatted summary below stays clean. A long cask download would
        # otherwise look frozen with everything sent to /dev/null.
        if test $n -gt 0
            echo "    "(set_color brblack)"upgrading $n package(s)… (this can take a while for large casks)"(set_color normal)
        end
        if brew upgrade >/dev/null; and brew upgrade --greedy >/dev/null; and brew cleanup >/dev/null
            if test $n -gt 0
                for i in (seq $n)
                    echo "    $brew_names[$i]  $brew_old[$i] → $brew_new[$i] "(set_color green)"✓"(set_color normal)
                end
                set total_updated (math $total_updated + $n)
                echo "  "(set_color green)"✓ $n packages upgraded"(set_color normal)
            else
                echo "  "(set_color green)"✓ all up to date"(set_color normal)
            end
        else
            echo "  "(set_color red)"✘ upgrade failed"(set_color normal)
            set failures (math $failures + 1)
        end
    else
        echo "  "(set_color yellow)"⚠ Homebrew not found, skipping"(set_color normal)
    end
    echo ""

    # ── pnpm -g ───────────────────────────────────────
    echo (set_color cyan --bold)"  pnpm -g"(set_color normal)
    if command -q pnpm
        set -lx PNPM_HOME "$HOME/Library/pnpm"
        if not contains -- "$PNPM_HOME/bin" $PATH
            set -lx PATH "$PNPM_HOME/bin" $PATH
        end

        set -l pnpm_before (pnpm --version 2>/dev/null)

        if command -q corepack
            if corepack enable >/dev/null 2>&1; and corepack prepare pnpm@latest-11 --activate >/dev/null 2>&1
                set -l pnpm_after (pnpm --version 2>/dev/null)
                if test -n "$pnpm_before"; and test -n "$pnpm_after"; and test "$pnpm_before" != "$pnpm_after"
                    echo "    pnpm  $pnpm_before → $pnpm_after "(set_color green)"✓"(set_color normal)
                    set total_updated (math $total_updated + 1)
                else
                    echo "    pnpm  $pnpm_after "(set_color green)"✓"(set_color normal)
                end
            else
                echo "    pnpm self-update "(set_color red)"✘"(set_color normal)
                set failures (math $failures + 1)
            end
        else
            echo "    "(set_color yellow)"⚠ corepack not found, skipping pnpm self-update"(set_color normal)
        end

        # Snapshot outdated before upgrade
        set -l pnpm_names
        set -l pnpm_old
        set -l pnpm_new
        for line in (pnpm outdated -g 2>/dev/null | tail -n +2)
            set -l parts (string match -r '(\S+)\s+(\S+)\s+\S+\s+(\S+)' $line 2>/dev/null)
            if test (count $parts) -ge 4
                set -a pnpm_names $parts[2]
                set -a pnpm_old $parts[3]
                set -a pnpm_new $parts[4]
            end
        end
        set -l n (count $pnpm_names)

        if pnpm update -g >/dev/null 2>&1
            if test $n -gt 0
                for i in (seq $n)
                    echo "    $pnpm_names[$i]  $pnpm_old[$i] → $pnpm_new[$i] "(set_color green)"✓"(set_color normal)
                end
                set total_updated (math $total_updated + $n)

                # Sync opsx commands if openspec was updated
                set -l openspec_updated false
                for name in $pnpm_names
                    if string match -q '*openspec*' $name
                        set openspec_updated true
                        break
                    end
                end
                if test "$openspec_updated" = true
                    openspec update >/dev/null 2>&1
                    if test -d .claude/commands/opsx
                        set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
                        if test -n "$git_root"
                            mkdir -p "$git_root/claude/.claude/commands/opsx"
                            cp .claude/commands/opsx/*.md "$git_root/claude/.claude/commands/opsx/"
                            echo "    "(set_color cyan)"opsx → claude/.claude/commands/opsx/"(set_color normal)
                        end
                    end
                end

                echo "  "(set_color green)"✓ $n packages updated"(set_color normal)
            else
                echo "  "(set_color green)"✓ all up to date"(set_color normal)
            end
        else
            echo "  "(set_color red)"✘ update failed"(set_color normal)
            set failures (math $failures + 1)
        end
    else
        echo "  "(set_color yellow)"⚠ pnpm not found, skipping"(set_color normal)
    end
    echo ""

    # ── uv tool (PyPI + Git combined) ─────────────────
    echo (set_color cyan --bold)"  uv tool"(set_color normal)
    if command -q uv
        # Identify git tool names
        set -l git_tool_names
        for line in (uv tool list --show-version-specifiers 2>/dev/null)
            set -l gm (string match -r -- '^(\S+)\s+v\S+\s+\[required:\s+git\+' $line 2>/dev/null)
            if test (count $gm) -ge 2
                set -a git_tool_names $gm[2]
            end
        end

        # Collect PyPI outdated
        set -l pypi_names
        set -l pypi_old
        set -l pypi_new
        for line in (uv tool list --outdated 2>/dev/null)
            set -l m (string match -r -- '^(\S+)\s+v(\S+)\s+\[latest:\s+(\S+)\]$' $line 2>/dev/null)
            if test (count $m) -ge 4
                set -l is_git false
                for gn in $git_tool_names
                    if test "$gn" = "$m[2]"
                        set is_git true
                        break
                    end
                end
                if test "$is_git" = false
                    set -a pypi_names $m[2]
                    set -a pypi_old $m[3]
                    set -a pypi_new $m[4]
                end
            end
        end

        # Collect Git outdated via GitHub API
        set -l git_names
        set -l git_old
        set -l git_new
        set -l git_urls
        for line in (uv tool list --show-version-specifiers 2>/dev/null)
            set -l gm (string match -r -- '^(\S+)\s+v(\S+)\s+\[required:\s+git\+(.+)\]$' $line 2>/dev/null)
            if test (count $gm) -ge 4
                set -l name $gm[2]
                set -l ver $gm[3]
                set -l url (string replace -r '@\S+$' '' $gm[4])
                set -l repo_match (string match -r -- 'https://github.com/([^/]+)/([^/]+?)(?:\.git)?$' $url 2>/dev/null)
                if test (count $repo_match) -ge 3
                    set -l release (curl -s "https://api.github.com/repos/$repo_match[2]/$repo_match[3]/releases/latest" 2>/dev/null)
                    set -l latest_tag (echo "$release" | jq -r '.tag_name // empty' 2>/dev/null)
                    if test -n "$latest_tag"
                        set -l latest_ver (string replace -r '^v' '' $latest_tag)
                        set -l current_ver (string replace -r '^v' '' $ver)
                        if test "$current_ver" != "$latest_ver"; and test -n "$latest_ver"
                            set -a git_names $name
                            set -a git_old "v$ver"
                            set -a git_new $latest_tag
                            set -a git_urls $url
                        end
                    end
                end
            end
        end

        # Execute upgrades and collect results
        set -l uv_res_name
        set -l uv_res_old
        set -l uv_res_new
        set -l uv_res_ok

        # PyPI upgrade
        set -l pypi_ok true
        if test (count $pypi_names) -gt 0
            uv tool upgrade --all >/dev/null 2>&1; or set pypi_ok false
        end
        for i in (seq (count $pypi_names))
            set -a uv_res_name $pypi_names[$i]
            set -a uv_res_old $pypi_old[$i]
            set -a uv_res_new $pypi_new[$i]
            set -a uv_res_ok $pypi_ok
        end

        # Git upgrade (individually)
        for i in (seq (count $git_names))
            set -l ok true
            uv tool install --from "git+$git_urls[$i]@$git_new[$i]" --force $git_names[$i] >/dev/null 2>&1; or set ok false
            set -a uv_res_name $git_names[$i]
            set -a uv_res_old $git_old[$i]
            set -a uv_res_new $git_new[$i]
            set -a uv_res_ok $ok
        end

        # Display combined results
        set -l total (count $uv_res_name)
        set -l n_ok 0
        if test $total -gt 0
            for i in (seq $total)
                if test "$uv_res_ok[$i]" = true
                    echo "    $uv_res_name[$i]  $uv_res_old[$i] → $uv_res_new[$i] "(set_color green)"✓"(set_color normal)
                    set n_ok (math $n_ok + 1)
                else
                    echo "    $uv_res_name[$i]  $uv_res_old[$i] → $uv_res_new[$i] "(set_color red)"✘"(set_color normal)
                end
            end
            set total_updated (math $total_updated + $n_ok)
            if test $n_ok -eq $total
                echo "  "(set_color green)"✓ $total packages upgraded"(set_color normal)
            else
                echo "  "(set_color yellow)"✓ $n_ok/$total packages upgraded"(set_color normal)
                set failures (math $failures + 1)
            end
        else
            echo "  "(set_color green)"✓ all up to date"(set_color normal)
        end
    else
        echo "  "(set_color yellow)"⚠ uv not found, skipping"(set_color normal)
    end
    echo ""

    # ── pi (self + packages) ─────────────────────────
    echo (set_color cyan --bold)"  pi"(set_color normal)
    if command -q pi
        # Let pi stream its own "Updating…" progress — swallowing it
        # makes large updates look frozen (same trap as Homebrew).
        if pi update --all
            echo "  "(set_color green)"✓ pi + packages updated"(set_color normal)
        else
            echo "  "(set_color red)"✘ update failed"(set_color normal)
            set failures (math $failures + 1)
        end
    else
        echo "  "(set_color yellow)"⚠ pi not found, skipping"(set_color normal)
    end
    echo ""

    # ── Summary ───────────────────────────────────────
    set -l end_time (date +%s)
    set -l elapsed (math $end_time - $start_time)

    if test $failures -eq 0
        if test $total_updated -gt 0
            echo (set_color green --bold)"  ✓ All upgrades complete — $total_updated packages updated ($elapsed s)"(set_color normal)
        else
            echo (set_color green --bold)"  ✓ All up to date ($elapsed s)"(set_color normal)
        end
    else
        echo (set_color red --bold)"  ✘ $failures source(s) failed — $total_updated packages updated ($elapsed s)"(set_color normal)
    end
    echo ""

    test $failures -eq 0
end
