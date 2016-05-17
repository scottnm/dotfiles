let mapleader="-"

set ruler                            " show row/column number
set backspace=2                      " backspace in insert mode works like normal editor
filetype indent on                   " activates indenting for files
filetype plugin on
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

" shortcuts
nnoremap <C-t> :tabnew<CR>|              " ctrl-t to open up a new tab
nnoremap <Tab> :tabnext<CR>|             " tab goes to the next tab 
nnoremap <S-Tab> :tabprev<CR>|           " shift tab goes to prev tab
inoremap <C-w> <c-o>:update<CR>|         " ctrl save
nnoremap <C-w> :update<CR>|              " ctrl save

" Syntax corrections
au BufRead, BufNewFile *.pde setfiletype java " fix processing syntax highlighting

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

" Plugins 
set nocompatible
if empty(glob('~/.vim/autoload/plug.vim'))
   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
       \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin() 
Plug 'itchyny/lightline.vim'
Plug 'flazz/vim-colorschemes'
Plug 'kien/rainbow_parentheses.vim'
Plug 'qualiabyte/vim-colorstepper'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
call plug#end()

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
