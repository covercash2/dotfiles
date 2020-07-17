function fish_mode_prompt --description 'displays current vi mode'
	switch $fish_bind_mode
		case default
			printf "%s%s" (set_color blue) 'ⓝ '
		case insert
			printf "%s%s" (set_color white) 'ⓘ '
		case visual
			printf "%s%s" (set_color purple) 'ⓥ '
	end
	
	set_color normal
end
