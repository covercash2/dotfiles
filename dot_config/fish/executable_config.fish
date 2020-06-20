# fish main config

# node config
set nodeversion (cat ~/.nvm/alias/default)
set nodebin ~/.nvm/versions/node/v$nodeversion/bin/

# load makeinfo from brew
set makeinfo /usr/local/opt/texinfo/bin 

set path $nodebin $makeinfo

# fenv is an oh-my-fish plugin
fenv source ~/.nix-profile/etc/profile.d/nix.sh

# enable direnv
eval (direnv hook fish)

for p in $path
	if test -d $p
		set PATH $PATH $p
	end
end
