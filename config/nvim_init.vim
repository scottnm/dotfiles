set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if has('unix')
    source ~/.vimrc
else " windows
    source ~/_vimrc
endif
