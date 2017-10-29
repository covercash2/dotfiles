# print pretty status message
function git_pretty_status
	    function _git_branch_name
        echo (git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
    end
    function _is_git_dirty
        echo (git status -s --ignore-submodules=dirty ^/dev/null)
    end

    if [ (_git_branch_name) ]
        set -l git_branch (set_color -o blue)(_git_branch_name)

	set git_status (git_status_symbol)

        set git_info "$git_branch$git_status"
    end

    printf "%s" $git_info
end
