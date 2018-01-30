# fish main config

set cargo ~/.cargo
set cask ~/.cask/bin
set go /usr/local/go
set gobin $go/bin

set homebin ~/bin

set path $cargo/bin $cask $gobin $homebin

set --export GOPATH $go
set --export CARGO_HOME $cargo

for p in $path
	if test -d $p
		set PATH $PATH $p
	end
end

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
