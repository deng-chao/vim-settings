#!/bin/bash

user_home_dir="$(echo ~)"

hasapt="$(command -v apt)"
hasyum="$(command -v yum)"
hasbrew="$(command -v brew)"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root, exit" 1>&2
   exit 1
fi

check_installed(){
  if [[ "$1" -ne "0" ]]; then
    echo "Failed to install $2, exit" && exit
  fi

}


if [[ "$hasapt" ]]; then

  echo "using apt to install necessery dependency"

  apt install libboost-all-dev
  check_installed $? "boost"

  apt install ctags
  check_installed $? "ctags"


elif [[ "$hasyum" ]]; then

  echo "using yum to install necessery dependency"
  yum install boost-devel
  check_installed $? "boost"

  yum install ctags
  check_installed $? "ctags"

elif [[ "$hasbrew" ]]; then

  echo "using brew to install necessery dependency"
#  brew install ctags
#  echo 'export PATH="/usr/local/bin/":$PATH' >> ~/.zshrc
#  source ~/.zshrc
else 
   echo "not support"
fi

if [[ -e ~/.vimrc ]]; then
  time="$(date +%Y%m%d%H%M%S)"
  echo "rename current .vimrc file to .vimrc-$time.bak"
  mv "$user_home_dir.vimrc" "$user_home_dir.vimrc-"$time".bak"
fi
cp "$user_home_dir/vimrc" "$user_home_dir.vimrc"

vim +VimEnter +PlugInstall +qall

if [[ -d ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm ]]; then
  if [[ ! -f ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py ]]; then
    echo "YouCompleteMe plugin installed, download .ycm_extra_conf.py"
    wget https://raw.githubusercontent.com/alanxz/rabbitmq-c/master/.ycm_extra_conf.py -P ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm
  fi

  echo "compile YouCompleteMe enable clang support"
#  ~/.vim/plugged/YouCompleteMe/install.py --clang-completer
fi
