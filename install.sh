ln -s $HOME/Development/dotfiles/.git-commit-template.txt $HOME/.git-commit-template.txt

ln -s $HOME/Development/dotfiles/.vimrc $HOME/.vimrc

ln -s $HOME/Development/dotfiles/.colormake.sh $HOME/.colormake.sh

ln -s $HOME/Development/dotfiles/.zshrc $HOME/.zshrc

ln -s $HOME/Development/dotfiles/.tmux.conf $HOME/.tmux.conf

ln -s $HOME/Development/dotfiles/.gitignore_global $HOME/.gitignore_global && git config --global core.excludesfile ~/.gitignore_global

ln -s $HOME/Development/dotfiles/rainbow_parentheses.vim/autoload/rainbow_parentheses.vim $HOME/.vim/autoload/rainbow_parentheses.vim

ln -s $HOME/Development/dotfiles/rainbow_parentheses.vim/plugin/rainbow_parentheses.vim $HOME/.vim/plugin/rainbow_parentheses.vim

git submodule init

git submodule update
