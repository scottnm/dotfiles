set backspace=2                      " backspace in insert mode works like normal editor
filetype indent on                   " activates indenting for files
filetype plugin on
set autoindent smartindent           " auto and smart indenting
set relativenumber number            " relative line numbers
set ignorecase smartcase             " case preferences
set nobackup                         " get rid of anoying ~file
set tabstop=4 shiftwidth=4 expandtab " tabs are size 4, indents size 4, tabs into spaces
set incsearch showmatch              " search options
set lazyredraw ttyfast               " faster rendering 
syntax on                            " syntax highlighting
set cindent                          " prevent the # mark from unindenting
set cinkeys-=0#
set indentkeys-=0#

" unmap arrow keys
map <Up> <NOP>
map <Down> <NOP>
map <Left> <NOP>
map <Right> <NOP>
set ruler               " show row/column number

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
execute pathogen#infect()

" YOU COMPLETE ME
set nocompatible
set rtp+=$HOME/.vim/bundle/vundle.vim
call vundle#begin()
Plugin 'Vundle/vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'itchyny/lightline.vim'
call vundle#end()

set laststatus=2
set hidden
set mat=0
set wildmenu
set wildmode=list:longest,full
set autoread
set magic

let mapleader="-"

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

if !has('gui_running')
  set t_Co=256
endif

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
