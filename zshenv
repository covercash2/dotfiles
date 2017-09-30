zsh=~/.oh-my-zsh

if [[ `uname` == Darwin ]]
then
	java=`/usr/libexec/java_home`
else
	java="/usr/lib/jvm/default-java"
fi

android_sdk=/usr/local/opt/android-sdk

mysql=/usr/local/mysql/bin

virtualbox=/Applications/VirtualBox.app/Contents/MacOS

go=~/code/go
go_workspace=${go}
go_bin=${go}/bin

cargo=~/.cargo

cask=~/.cask/bin

mysql=/usr/local/mysql/

homebin=~/bin

export MYSQL_PATH=$mysql

export JAVA_HOME=$java
export ANDROID_HOME=$android_sdk
export ZSH=$zsh
export GOPATH=$go_workspace
export CARGO_HOME=$cargo

export PATH=$PATH:$mysql:$virtualbox:$go_bin:$cargo/bin:$homebin:$cask

