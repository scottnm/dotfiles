set backspace=2         " backspace in insert mode works like normal editor
syntax on               " syntax highlighting
filetype indent on      " activates indenting for files
set autoindent          " auto indenting
set relativenumber      " relative line numbers
set nobackup            " get rid of anoying ~file
set tabstop=4           " tabs are size 4
set shiftwidth=4        " indents are size 4
set expandtab           " turn tabs into spaces
colorscheme desert      " desert color scheme

" unmap arrow keys
map <Up> <NOP>
map <Down> <NOP>
map <Left> <NOP>
map <Right> <NOP>
set ruler               " show row/column number

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
execute pathogen#infect()

" YOU COMPLETE ME JUNK

set nocompatible

filetype off
set rtp+=$HOME/.vim/bundle/vundle.vim

call vundle#begin()
Plugin 'Vundle/vundle.vim'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()

set smartindent
set laststatus=2
set number
set hidden
set ignorecase
set smartcase
set incsearch
set showmatch
set mat=0
set wildmenu
set wildmode=list:longest,full
set autoread
set smarttab
set lazyredraw
set ttyfast
set magic

" The <Leader> substitute character.
let mapleader=","

" Quicker OS clipboard copy/paste
nmap <Leader>y "*y
vmap <Leader>y "*y
nmap <Leader>d "*d
vmap <Leader>d "*d
nmap <Leader>p "*p
vmap <Leader>p "*p
nmap <Leader>P "*P
vmap <Leader>P "*P
nmap <Leader>x "*x
vmap <Leader>x "*x
