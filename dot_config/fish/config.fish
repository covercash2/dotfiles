# fish main config

# node config
if test	-d ~/.nvm
	set nodeversion (cat ~/.nvm/alias/default)
	set nodebin ~/.nvm/versions/node/v$nodeversion/bin/

	set path $nodebin $path
end

# load makeinfo from homebrew
# mac specific
if test -d
	set makeinfo /usr/local/opt/texinfo/bin 
	set path $makeinfo $path
end

for p in $path
	if test -d $p
		set PATH $PATH $p
	end
end
