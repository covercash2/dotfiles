function git_status_symbol --description "symbolic git status in unicode chars"

	if [ (is_git_dirty) ]
		for i in (git branch -qv --no-color | string match -r '\*' \
			| cut -d' ' -f4- | cut -d] -f1 | tr , \n)\
			(git status --porcelain | cut -c 1-2 | uniq)

			set bracket_color yellow

			set open_bracket (set_color $bracket_color)"<"(set_color normal)
			set close_bracket (set_color $bracket_color)">"(set_color normal)

			switch $i
			    case "*[ahead *"
				set list $list (set_color red)"⬆"
			    case "*behind *"
				set list $list (set_color red)"⬇"
			    case "."
				set list $list (set_color bryellow)"✚"
			    case " D"
				set list $list (set_color yellow)"⨷"
			    case "*M*"
				set list $list (set_color cyan)"✱"
			    case "*R*"
				set list $list (set_color purple)"➜"
			    case "*U*"
				set list $list (set_color brown)"═"
			    case "??"
				set list $list (set_color cyan)"✦"
			end
            end
        else
		# when git is up to date
		#set git_status (set_color green)"◈"
	end

	printf "%s" $open_bracket

	echo $list

	printf "%s" $close_bracket
end
