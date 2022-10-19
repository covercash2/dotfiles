# fish main config

set homebin ~/.local/bin

# node config
if test -d $HOME/.nvm
	set nodeversion (cat ~/.nvm/alias/default)
	set nodebin ~/.nvm/versions/node/v$nodeversion/bin/

	logger -p user.info "node works"
else
	logger -p user.info "nvm/node not configured"
end

# os specific stuff
set os (uname)
switch $os
	case Linux
		# linux found
	case Darwin
# load makeinfo from brew
			set makeinfo /usr/local/opt/texinfo/bin 
			if test -d $makeinfo
				set path $nodebin $makeinfo $homebin

				logger -p user.info \
				"makeinfo works"
			else
				logger -p user.warning \
				"makeinfo doesn't work"
			end
	case '*'
		logger -p user.warning --stderr \
		"weird os detected: $os"
end

# if oh-my-fish is installed
if test -d $HOME/.local/share/omf
# fenv is an oh-my-fish plugin
	if test -e $HOME/.profile
		fenv source $HOME/.profile
	else
		logger -p user.warning --stderr \
		"could not find ~/.profile"
	end
else
	logger -p user.warning \
	"oh-my-fish wasn't detected"
end

if which direnv > /dev/null 2>&1
# enable direnv
	eval (direnv hook fish)
end

for p in $path
	if test -d $p
		set PATH $PATH $p
	end
end

# starship prompt manager
# https://starship.rs
if type -q starship
    starship init fish | source
else
	logger -p user.warning \
	"starship prompt manager wasn't detected"
end

status is-login; and pyenv init --path | source
status is-interactive; and pyenv init - | source

source /usr/local/opt/asdf/libexec/asdf.fish
