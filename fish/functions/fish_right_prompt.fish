# right justified prompt
function fish_right_prompt

	if test $status -eq 0
		set laststatus "✔"
	else
		set laststatus $status
	end

	set git_info (git_pretty_status)

	printf "%s %s%s" $git_info (set_color -o cyan) (date +'❰%m/%d ❙ %H:%M:%S❱')
end
