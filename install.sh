CONFIGDIR="$HOME"/dev/dotfiles/config

ln -s "$CONFIGDIR/.git-commit-template" "$HOME/.git-commit-template"

ln -s "$CONFIGDIR/.vimrc" "$HOME/.vimrc"

ln -s "$CONFIGDIR/.colormake.sh" "$HOME/.colormake.sh"

ln -s "$CONFIGDIR/.sshlab.sh" "$HOME/.sshlab.sh"

ln -s "$CONFIGDIR/.zshrc" "$HOME/.zshrc"

ln -s "$CONFIGDIR/.gitignore_global" "$HOME/.gitignore_global" && git config --global core.excludesfile ~/.gitignore_global
