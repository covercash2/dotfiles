# right justified prompt
function fish_right_prompt
	if test $status -eq 0
		set laststatus (set_color green)"◈"
	else
		set laststatus (set_color -o brred)$status
	end

	set git_info (set_color -o blue)(git_branch_name)(set_color yellow)ᛦ\
	(git_status_symbol)

	set time_str (set_color brblack)" ❰"(set_color blue)\
	(date +'%H:%M:%S')(set_color brblack)" ❱"

	printf "%s %s⁞ " $laststatus (set_color brblack)

	printf "%s %s\n%s" $git_info (set_color normal) $time_str
end
