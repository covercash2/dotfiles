# fish main config

set android ~/code/libs/android
set ndk_version 20.0.5594570
set ndk "$android/ndk/$ndk_version"

set cargo ~/.cargo
set cask ~/.cask/bin
set flutter ~/code/libs/flutter
set go /usr/local/go
set gobin $go/bin

# node config
set nodeversion (cat ~/.nvm/alias/default)
set nodebin ~/.nvm/versions/node/v$nodeversion/bin/

set homebin ~/bin

set path $android $cargo/bin $cask $flutter/bin $gobin $homebin $nodebin

set --export ANDROID_HOME $android
set --export NDK_HOME $ndk

set --export GOPATH $go
set --export CARGO_HOME $cargo

for p in $path
	if test -d $p
		set PATH $PATH $p
	end
end

# load makeinfo from brew
set PATH /usr/local/opt/texinfo/bin $PATH

# fish configs
set fish_color_command -o white
set fish_color_normal brred
set fish_color_param bryellow
set fish_color_quote brcyan

# set vi mode on
fish_vi_key_bindings

# color man pages with most
# TODO check if most exists
set --export MOST_INITFILE ~/.config/mostrc
set --export PAGER 'most'
