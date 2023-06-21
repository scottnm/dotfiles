#!/bin/bash

set -e

WINDOWS_USER=$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2> /dev/null | sed -e 's/\r//g')

# This script will...

# 1. make sure that my .profile is set
echo "seting unix profile..."
UNIX_PROFILE="$HOME/.profile"
rm -f $UNIX_PROFILE
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/unix_profile" $UNIX_PROFILE
echo "...set unix profile!"

# 2. make sure that package repos are updated
echo "updating package repos..."
sudo apt update
echo "...updated package repos!"

# 3a. make sure that vim is installed
echo "installing neovim..."
sudo apt remove vim
sudo apt install neovim
echo "...neovim installed"

# 3b. make sure that curl is installed
echo "installing curl..."
sudo apt install curl
echo "...curl installed"

# 3c. make sure that git is installed
echo "installing git..."
sudo apt install git
echo "...git installed"

# 4. make sure that my vimrc is properly aliased so that it can be loaded
echo "linking vimrc..."
VIM_CONFIG="$HOME/.vimrc"
rm -f $VIM_CONFIG
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/_vimrc" $VIM_CONFIG
echo "...vimrc linked"

echo "linking gvimrc..."
GVIM_CONFIG="$HOME/.gvimrc"
rm -f $GVIM_CONFIG
ln -s "$DOTFILES/config/.gvimrc" $GVIM_CONFIG
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/.gvimrc" $GVIM_CONFIG
echo "...gvimrc linked"

echo "setting up nvim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p $NVIM_CONFIG_DIR

echo "    linking nvim init.vim..."
NVIM_CONFIG="$NVIM_CONFIG_DIR/init.vim"
rm -f $NVIM_CONFIG
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/nvim_init.vim" $NVIM_CONFIG
echo "    ...nvim init.vim linked"

echo "   linking nvim ginit.vim..."
NVIM_GCONFIG="$NVIM_CONFIG_DIR/ginit.vim"
rm -f $NVIM_GCONFIG
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/nvim_ginit.vim" $NVIM_GCONFIG
echo "    ...nvim ginit.vim linked"

echo "...nvim config setup"

# 5. symlink inputrc to our home directory
echo "linking inputrc..."
INPUT_RC="$HOME/.inputrc"
rm -f $INPUT_RC
ln -s "/mnt/c/Users/$WINDOWS_USER/dev/dotfiles/config/.inputrc" $INPUT_RC
echo "...inputrc linked"
