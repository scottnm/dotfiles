ln -s "$HOME/dev/dotfiles/.git-commit-template.txt" "$HOME/.git-commit-template.txt"

ln -s "$HOME/dev/dotfiles/.vimrc" "$HOME/.vimrc"

ln -s "$HOME/dev/dotfiles/.colormake.sh" "$HOME/.colormake.sh"

ln -s "$HOME/dev/dotfiles/.zshrc" "$HOME/.zshrc"

ln -s "$HOME/dev/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

ln -s "$HOME/dev/dotfiles/.gitignore_global" "$HOME/.gitignore_global && git config --global core.excludesfile ~/.gitignore_global"
