function fish_prompt --description 'Write out the prompt'
	set laststatus $status

	if test $USER = chrash
		set user "⚇ "
	else
		set user (string join0 $USER "@")
	end

	set current_dir $PWD
	set max_dir_length 30

	set current_dir (string replace "$HOME" "~" "$PWD")

	if test (string length $current_dir) -gt $max_dir_length
		set current_dir ..\
			(string sub --start=-$max_dir_length $current_dir)
	end

	printf '%s%s%s%s%s%s%s%s%s%s%s%s' (set_color blue)\
	$user (set_color -o brgreen) (cat /etc/hostname) \
	(set_color brblue) \
	$current_dir (set_color white)

	set command_start "⇒"

	printf "\n%s%s " (set_color normal) $command_start

	set_color normal
end

