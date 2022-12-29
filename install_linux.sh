#!/bin/sh

GIT_CONFIG=~/.gitconfig
rm -f $GIT_CONFIG
ln -s ~/dev/dotfiles/config/.gitconfig $GIT_CONFIG

UNIX_PROFILE=~/.profile
rm -f $UNIX_PROFILE
ln -s ~/dev/dotfiles/config/unix_profile $UNIX_PROFILE

FISH_CONFIG_DIR=~/.config/fish
FISH_CONFIG=$FISH_CONFIG_DIR/config.fish
rm -rf $FISH_CONFIG_DIR
mkdir $FISH_CONFIG_DIR
ln -s ~/dev/dotfiles/config/config.fish $FISH_CONFIG

VIM_CONFIG=~/.vimrc
rm -f $VIM_CONFIG
ln -s ~/dev/dotfiles/config/_vimrc $VIM_CONFIG
