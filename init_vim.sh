#!/bin/bash

check_installed(){
  if [[ "$1" -ne "0" ]]; then
    echo "Failed to install $2, exit" && exit
  fi
}

# append '/' to the end of path if the last char isn't '/'
format_path(){
    case $1 in
        */) echo $1 ;;
        *) echo "$1/" ;;
    esac
}

user_home_dir="$(format_path "$(echo ~)")"
echo "home dir: $user_home_dir"

current_dir="$(format_path "$(pwd)")"
echo "current dir: $current_dir"

hasapt="$(command -v apt-get)"
hasyum="$(command -v yum)"
hasbrew="$(command -v brew)"

#if [ "$(id -u)" != "0" ]; then
#   echo "This script must be run as root, exit" 1>&2
#   exit 1
#fi

vim_major_version="$(vim --version | head -1 | cut -d ' ' -f 5 | cut -d '.' -f 1)"
vim8="$(test "$vim_major_version" -ne "8" )"

if [[ "$vim_major_version" -ne "8" ]]; then
  # -qq -o=Dpkg::Use-Pty=0 to avoid printing a lot of noisy log
  sudo apt install -y -qq -o=Dpkg::Use-Pty=0 ncurses-dev
  wget https://github.com/vim/vim/archive/master.zip
  unzip master.zip
  cd vim-master
  cd src/
  ./configure
  make 
  make install
  hash vim
fi

cd $current_dir

if [[ "$hasapt" ]]; then
  echo "using apt to install necessery dependency"

  ! $vim8 && sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 liblua5.1-dev luajit libluajit-5.1 python-dev ruby-dev \
   libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev

  apt install libboost-all-dev
  check_installed $? "boost"

  apt install ctags
  check_installed $? "ctags"

  echo "dependency installed"

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

cp "$current_dir""vimrc" "$user_home_dir""/.vimrc"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +VimEnter +PlugInstall +qall

if [[ -d ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm ]]; then
  if [[ ! -f ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py ]]; then
    echo "YouCompleteMe plugin installed, download .ycm_extra_conf.py"
    wget https://raw.githubusercontent.com/alanxz/rabbitmq-c/master/.ycm_extra_conf.py -P ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm
  fi

  echo "compile YouCompleteMe enable clang support"
#  ~/.vim/plugged/YouCompleteMe/install.py --clang-completer
fi
