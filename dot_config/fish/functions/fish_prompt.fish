function fish_prompt --description 'Write out the prompt'
	set laststatus $status

	if test $USER = chrash
		set user "⚇ "
	else
		set user (string join0 $USER "@")
	end

	set workspace_info 

	printf '%s%s%s%s%s%s%s%s%s%s%s%s' (set_color blue)\
	$user (set_color -o brgreen) (cat /etc/hostname) \
	(set_color brblue) \
	(echo $PWD | sed -e "s|^$HOME|~|") (echo /)(set_color white) (set_color white) \
	(set_color white)

	set command_start "⇒"

	printf "\n%s%s " (set_color normal) $command_start

	set_color normal
end

