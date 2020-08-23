# Defined in - @ line 2
function ls --description 'redirect ls to exa'
	exa $argv
	if test ! $status
		echo "exa failed; falling back to /bin/ls"
		/bin/ls $argv
	end
end
