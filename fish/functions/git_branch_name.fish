function git_branch_name
	printf "%s" (git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end
