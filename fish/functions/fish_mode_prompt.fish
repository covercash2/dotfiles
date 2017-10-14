function fish_mode_prompt --description 'displays current vi mode'
	switch $fish_bind_mode
		case default
			set_color --bold --background green black
			echo '[n]'
		case insert
			set_color --bold --background blue black
			echo '[i]'
		case visual
			set_color --bold --background purple black
			echo '[v]'
	end
	
	set_color normal
	echo -n ' '
end
