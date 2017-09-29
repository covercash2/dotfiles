#!/bin/bash

env=$(realpath ./zshenv)
rc=$(realpath ./zshrc)

env_loc=$HOME/.zshenv
rc_loc=$HOME/.zshrc

ln -s $env $env_loc
ln -s $rc $rc_loc
