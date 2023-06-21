#!/bin/sh

# to download this remotely use...
# wget https://raw.githubusercontent.com/scottnm/dotfiles/master/install_linux.sh -O ~/Downloads/install_linux.sh && chmod +x ~/Downloads/install_linux

set -e

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

echo "linking gvimrc..."
GVIM_CONFIG="$HOME/.gvimrc"
rm -f $GVIM_CONFIG
ln -s "$DOTFILES/config/.gvimrc" $GVIM_CONFIG
echo "...gvimrc linked"

echo "setting up nvim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p $NVIM_CONFIG_DIR

echo "   linking nvim init.vim..."
NVIM_CONFIG="$NVIM_CONFIG_DIR/init.vim"
rm -f $NVIM_CONFIG
ln -s "$DOTFILES/config/nvim_init.vim" $NVIM_CONFIG
echo "    ...nvim init.vim linked"

echo "   linking nvim ginit.vim..."
NVIM_GCONFIG="$NVIM_CONFIG_DIR/ginit.vim"
rm -f $NVIM_GCONFIG
ln -s "$DOTFILES/config/nvim_ginit.vim" $NVIM_GCONFIG
echo "    ...nvim ginit.vim linked"

echo "...nvim config setup"

# 5. symlink inputrc to our home directory
echo "linking inputrc..."
INPUT_RC="$HOME/.inputrc"
rm -f $INPUT_RC
ln -s "$DOTFILES/config/.inputrc" $INPUT_RC
echo "...inputrc linked"
