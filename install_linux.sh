#!/bin/sh

# to download this remotely use...
# wget https://raw.githubusercontent.com/scottnm/dotfiles/master/install_linux.sh ~/Downloads/install_linux.sh

set -e

# GIT_CONFIG=~/.gitconfig
# rm -f $GIT_CONFIG
# ln -s ~/dev/dotfiles/config/.gitconfig $GIT_CONFIG
# 
# UNIX_PROFILE=~/.profile
# rm -f $UNIX_PROFILE
# ln -s ~/dev/dotfiles/config/unix_profile $UNIX_PROFILE
# 
# VIM_CONFIG=~/.vimrc
# rm -f $VIM_CONFIG
# ln -s ~/dev/dotfiles/config/_vimrc $VIM_CONFIG
# 
#### ^^^ BEFORE
#### vvv AFTER

# This script will...

# make sure that package repos are updated
echo "updating package repos..."
sudo apt update
echo "...updated package repos!"

# install dependencies
echo "Installing main tools..."
echo "    * git"
sudo apt install git
echo "    * neovim"
sudo apt install neovim
echo "    * curl"
sudo apt install curl
echo "...main tools installed"

# setup the dev and dotfiles directories
echo "Setting up dotfiles..."
DOTFILES="$HOME/dev/dotfiles"
rm -rf $DOTFILES
mkdir -p ~/dev
git clone https://github.com/scottnm/dotfiles $DOTFILES
echo "...dotfile setup"

# make sure that my .profile is set
echo "seting unix profile..."
UNIX_PROFILE="$HOME/.profile"
rm -f $UNIX_PROFILE
ln -s "$DOTFILES/config/unix_profile" $UNIX_PROFILE
echo "...set unix profile!"

# 4. make sure that my vimrc is properly aliased so that it can be loaded
echo "linking vimrc..."
VIM_CONFIG="$HOME/.vimrc"
rm -f $VIM_CONFIG
ln -s "$DOTFILES/config/_vimrc" $VIM_CONFIG
echo "...vimrc linked"

echo "linking nvim init.vim..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_CONFIG="$NVIM_CONFIG_DIR/init.vim"
mkdir -p $NVIM_CONFIG_DIR
rm -f $NVIM_CONFIG
ln -s "$DOTFILES/config/nvim_init.vim" $NVIM_CONFIG
echo "...nvim init.vim linked"

# 5. symlink inputrc to our home directory
echo "linking inputrc..."
INPUT_RC="$HOME/.inputrc"
rm -f $INPUT_RC
ln -s "$DOTFILES/config/.inputrc" $INPUT_RC
echo "...inputrc linked"
