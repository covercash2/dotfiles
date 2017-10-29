function git_status_symbol --description "symbolic git status in unicode chars"

	if [ (is_git_dirty) ]

		for i in (git branch -qv --no-color | string match -r '\*' \
			| cut -d' ' -f4- | cut -d] -f1 | tr , \n)\
			(git status --porcelain | cut -c 1-2 | uniq)

			switch $i
			    case "*[ahead *"
				set git_status "$git_status"(set_color red)" ⬆"
			    case "*behind *"
				set git_status "$git_status"(set_color red)" ⬇"
			    case "."
				set git_status "$git_status"(set_color green)" ✚"
			    case " D"
				set git_status "$git_status"(set_color red)" ✖"
			    case "*M*"
				set git_status "$git_status"(set_color green)" ✱"
			    case "*R*"
				set git_status "$git_status"(set_color purple)" ➜"
			    case "*U*"
				set git_status "$git_status"(set_color brown)" ═"
			    case "??"
				set git_status "$git_status"(set_color red)" ≠"
			end
            end
        else
            set git_status "✔"
	end

	echo $git_status
end
