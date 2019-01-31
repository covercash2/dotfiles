# fish main config

set android ~/code/libs/android
set cargo ~/.cargo
set cask ~/.cask/bin
set flutter ~/code/libs/flutter
set go /usr/local/go
set gobin $go/bin

set homebin ~/bin

set path $android $cargo/bin $cask $flutter/bin $gobin $homebin

set --export ANDROID_HOME $android
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
set --export PAGER 'most'
