#!/bin/sh

GIT_CONFIG=~/.gitconfig
rm $GIT_CONFIG
ln -s ~/dev/dotfiles/config/.gitconfig $GIT_CONFIG

UNIX_PROFILE=~/.profile
rm $UNIX_PROFILE
ln -s ~/dev/dotfiles/config/unix_profile $UNIX_PROFILE

FISH_CONFIG=~/.config/fish/config.fish
rm $FISH_CONFIG
ln -s ~/dev/dotfiles/config/config.fish $FISH_CONFIG
