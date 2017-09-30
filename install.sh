#!/bin/bash

emacs=$(realpath ./emacs.d)
env=$(realpath ./zshenv)
rc=$(realpath ./zshrc)

emacs_loc=$HOME/.emacs.d
env_loc=$HOME/.zshenv
rc_loc=$HOME/.zshrc

ln -s $emacs $emacs_loc
ln -s $env $env_loc
ln -s $rc $rc_loc


