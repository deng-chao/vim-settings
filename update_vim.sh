#!/bin/bash

vim_major_version="$(vim --version | head -1 | cut -d ' ' -f 5 | cut -d '.' -f 1)"
echo "$vim_major_version"
vim8="$(test "$vim_major_version" -ne "8" )"

! $vim8 && sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 liblua5.1-dev luajit libluajit-5.1 python-dev ruby-dev \
libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev

if [[ ! -z $vim8 ]]; then
  echo "aaa"
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