zsh=~/.oh-my-zsh

java=`/usr/libexec/java_home`

android_sdk=/usr/local/opt/android-sdk

mysql=/usr/local/mysql/bin

virtualbox=/Applications/VirtualBox.app/Contents/MacOS

go=~/code/go
go_workspace=${go}
go_bin=${go}/bin

mysql=/usr/local/mysql/

export MYSQL_PATH=$mysql

export JAVA_HOME=`/usr/libexec/java_home`
export ANDROID_HOME=$android_sdk
export ZSH=$zsh
export GOPATH=$go_workspace

export PATH=$PATH:$mysql:$virtualbox:$go_bin
