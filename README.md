# My development environment

File overview:

* *install.sh* - a script to add links to these dotfiles to the home directory. NOTE: This repo must be located at ~/dev/dotfiles for this script to function

* *uninstall.sh* - a script to remove all of the links to these dotfiles so your system won't use them. NOTE: This repo must be located at ~/dev/dotfiles for this script to function

* *config/*

    * *.colormake.sh* - A script that turns the Make program's output easier to read through colors.

    * *.git-commit-template* - A template for commit messages to encourage good practices

    * *plugin-list* - A poorly kept up list of all of the plugins that I like to use for various tools

    * *.sshlab.sh* - A script that is aliased in my zshrc to speed up logging into the lab machines. With the zshrc file setup, use sshlab <machinename> to login. NOTE: You will need to change the UTCS login name if you want to use this

    * *.vimrc* - My vim configuration

    * *.zshrc* - My zsh configuration. Used with oh-my-zsh to create a bunch of command aliases and make everything look beautiful
