# fish main config

set cargo ~/.cargo
set cask ~/.cask/bin
set go /usr/local/go
set gobin $go/bin

set --export GOPATH $go
set --export CARGO_HOME $cargo

set PATH $CARGO_HOME/bin $gobin $cask $PATH

# fish configs
set fish_color_command -o white
set fish_color_normal brred
set fish_color_param bryellow
set fish_color_quote brcyan

# set vi mode on
fish_vi_key_bindings
