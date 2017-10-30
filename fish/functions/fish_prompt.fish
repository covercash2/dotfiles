function fish_prompt --description 'Write out the prompt'
	set laststatus $status

	set git_info (git_branch_name)

	printf '%s%s%s%s%s%s%s%s%s%s%s%s' (set_color -o white) (set_color cyan) \
	$USER "@" (cat /etc/hostname) (set_color white) '⁞' (set_color yellow) \
	(echo $PWD | sed -e "s|^$HOME|~|") (set_color white) (set_color white) \
	(set_color white)

	if test $laststatus -eq 0
	    printf "%s\n%s▶%s " (set_color -o green) (set_color white) 
	else
	    printf "%s\n%s▶" (set_color -o red) (set_color white) 
	end

	set_color normal
end

