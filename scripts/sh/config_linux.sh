#!/bin/bash

rootdir=$HOME/system/dotfiles

ln -sf "$rootdir/zshrc" $HOME/.zshrc
ln -sf "$rootdir/zshenv" $HOME/.zshenv
ln -sf "$rootdir/nvim" $HOME/.config/nvim
ln -sf "$rootdir/emacs.d" $HOME/.emacs.d
ln -sf "$rootdir/xinitrc" $HOME/.xinitrc 
