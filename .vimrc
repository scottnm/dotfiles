set backspace=2         " backspace in insert mode works like normal editor
syntax on               " syntax highlighting
filetype indent on      " activates indenting for files
set autoindent          " auto indenting
set relativenumber      " relative line numbers
colorscheme desert      " colorscheme desert
set nobackup            " get rid of anoying ~file
set tabstop=4           " tabs are size 4
set shiftwidth=4        " indents are size 4
set expandtab           " turn tabs into spaces
noremap <Up> <NOP>      " remove the arrow keys
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
set ruler               " show row/column number

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
execute pathogen#infect()
