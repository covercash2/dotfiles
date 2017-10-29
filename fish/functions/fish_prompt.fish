function fish_prompt --description 'Write out the prompt'
	set laststatus $status

	printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s' (set_color -o white) '❰' (set_color green) \
	$USER "@" (cat /etc/hostname) (set_color white) '❙' (set_color yellow) \
	(echo $PWD | sed -e "s|^$HOME|~|") (set_color white) '❱' (set_color white) \
	(set_color white)

	if test $laststatus -eq 0
	    printf "%s\n✔ %s≻%s " (set_color -o green) (set_color white) (set_color normal)
	else
	    printf "%s\n$status %s≻%s " (set_color -o red) (set_color white) (set_color normal)
	end
end

