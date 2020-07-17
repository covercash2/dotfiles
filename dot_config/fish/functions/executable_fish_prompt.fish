function fish_prompt --description 'Write out the prompt'
	set laststatus $status

	set user $USER

	if test $user = chreeus
		set user ⚇
	end

	set workspace_info 

	printf '%s%s%s%s%s%s%s%s%s%s%s%s' (set_color blue)\
	$user (set_color cyan)"⇴" (set_color -o brgreen) (cat /etc/hostname) \
	(set_color brblack) '⁚' (set_color brblue) \
	(echo $PWD | sed -e "s|^$HOME|~|") (echo /)(set_color white) (set_color white) \
	(set_color white)

	set command_start "⇒"

	printf "\n%s%s " (set_color normal) $command_start

	set_color normal
end

