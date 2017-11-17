# right justified prompt
function fish_right_prompt
	set s $status

	# test if last command succeeded
	if test $s -eq 0
		set laststatus (set_color green)"◈"
	else
		set laststatus (set_color -o red)$s(set_color normal)
	end

	printf "%s %s" $laststatus (set_color brblack)

	set branch_name (git_branch_name)

	# if there is branch name
	if test $branch_name
		if test $branch_name = master
			set branch_name "ⓜ"
		end
		set git_info (set_color yellow)ᛦ(set_color blue)$branch_name\
		(git_status_symbol)

		printf "%s %s%s" $git_info (set_color normal) $time_str
	end

	set time_str (set_color brblack)"❰"(set_color white)\
	(date +'%T')(set_color brblack)"❱"

	printf "%s" $time_str
end
