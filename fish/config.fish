# fish main config

# set vi mode on
fish_vi_key_bindings

set cargo ~/.cargo
set cask ~/.cask/bin
set go /usr/local/go
set gobin $go/bin

set --export GOPATH $go
set --export CARGO_HOME $cargo

set PATH $CARGO_HOME/bin $gobin $cask $PATH
