""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  VIM PLUG                                      "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('unix')
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
else " windows
    if empty(glob('$HOME/vimfiles/autoload/plug.vim'))
        iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
            ni $HOME/vimfiles/autoload/plug.vim -Force
    endif
endif

call plug#begin('~/.vim/plugged')

" Vim Git Wrapper
Plug 'tpope/vim-fugitive'
" Toggle between header and source files
Plug 'vim-scripts/a.vim'
" Make yanked region flash
Plug 'machakann/vim-highlightedyank'
" Powershell goodness
Plug 'PProvost/vim-ps1'
" Distraction free writing
" usage :[!]Goyo
Plug 'junegunn/goyo.vim'
" Centered code buffer
Plug 'JMcKiern/vim-venter'
" fuzzy finder
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" journal
Plug 'junegunn/vim-journal'
" allow quitting all vim buffers except active
Plug 'vim-scripts/BufOnly.vim'
" tab line
Plug 'Yggdroot/indentLine'
" My fork of desert-night
Plug 'scottnm/vim-color-desert-night' " fork of 'sainnhe/vim-color-desert-night'
" line differ
Plug 'AndrewRadev/linediff.vim'
" vim markdown
Plug 'plasticboy/vim-markdown' " vim's default markdown highlighting is pretty funky. maybe this is better

"
"
" OTHER OPTIONAL PACKAGES
"
"
" " Kql
" Plug 'christianrondeau/vim-azure-log-analytics'
" " Pair shortcuts (e.g. [q ]q for :cprev :cnext
" Plug 'tpope/vim-unimpaired'
" " Advanced substitution handling casings and plurality
" Plug 'tpope/vim-abolish'
" " Show if-branch path
" Plug 'aserebryakov/vim-branch-stack'
" " Korean kolor
" Plug 'junegunn/seoul256.vim'
" " color schemes
" Plug 'NLKNguyen/papercolor-theme'
" Plug 'jonathanfilip/vim-lucius'
" Plug 'gregsexton/Gravity'
" Plug 'MichaelMalick/vim-colors-bluedrake'
" Plug 'atelierbram/vim-colors_atelier-schemes'
" Plug 'lifepillar/vim-solarized8'
" " haskell
" Plug 'neovimhaskell/haskell-vim' " syntax highlighting
" " rust
" Plug 'rust-lang/rust.vim' " highlighting + fmt support

" Initialize plugin system
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                              BEGIN CONFIG                                      "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set noerrorbells
if has('gui_running')
    set visualbell t_vb=
    autocmd GUIEnter * set visualbell t_vb=
endif

" prevent window movement when vsplit
set guioptions-=r
set guioptions-=L

set nobackup
set nowritebackup
set noundofile
set noswapfile

set shell=cmd
" set shellcmdflag=-command
if has('gui_running')
    " set guifont=Cascadia\ Mono:h11
    " set renderoptions=type:directx
    set guifont=Consolas:h11:cANSI:qDRAFT
    " autocmd GUIEnter * simalt ~x
    set lines=40 columns=125
    winpos 300 300
endif

set encoding=utf-8

set ruler                            " show row/column number
set backspace=2                      " backspace works in insert mode
filetype plugin on
set relativenumber number            " relative line numbers
set ignorecase smartcase             " case preferences
set nobackup
set softtabstop=4 shiftwidth=4 expandtab " tabs & indents size 4, tabkey = spaces
set incsearch hlsearch showmatch     " search options
set scrolloff=10                     " make it so search has at least 5 lines of padding below/above it
set lazyredraw ttyfast               " faster rendering
set smartindent                      " prevent the # mark from unindenting
set cinkeys-=0#
set indentkeys-=0#
set cursorline

let g:netrw_list_hide= '.*\.wav$,.*\.etl$'

" Update vim command 'tab' autocompletion to only complete the common bits
" i.e. :e R<tab> with items Red.cpp and Read.cpp would tab complete to :e Re
set wildmode=longest,list
set completeopt=longest,menuone,preview

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                 REMAP KEYS                                     "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" unmap arrow keys to encourage good vim practices
map <Up> <NOP>
map <Down> <NOP>
map <Left> <NOP>
map <Right> <NOP>

" Correct line movement to work properly with wrapping
nnoremap j gj
nnoremap k gk

" shortcuts
nnoremap   <C-p>  :bprev<CR>|                " prev buffer
nnoremap   <C-n>  :bnext<CR>|                " next buffer
nnoremap   <C-f>  :A<CR>|                    " flip buffer using a.vim
nnoremap   <C-h>  :noh<CR>|                  " clear search
nnoremap   <C-s>  :%s/\s\+$//gc<CR>|         " Delete trailing whitespace with confirmation
nnoremap   <C-G>  :%s/\<<C-R><C-W>\>/| ":bufdo %s/\<<C-R><C-W>\>//ge \| update | " grab as bounded word
nnoremap   <S-Enter> O<Esc>|
nnoremap   <CR> o<Esc>|
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR> " enable searching for visually selected text
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left> " enable replacing visually selected text

" leader key shortcuts
let mapleader="-"

" clipboard copy-paste support
:nnoremap <Leader>p "+gP
:nnoremap <Leader>P O<ESC>"+gP
:vnoremap <Leader>y "+y

" Better splits with vim
set splitbelow
set splitright

" show when I run over 120 columns
set colorcolumn=121
hi ColorColumn ctermbg=darkgray

" :ls to get buffers
" :b<N> to switch to the buffer

" experimental
nnoremap ; :
vnoremap ; :

" prevent unnecessary rewrites
set nofixendofline

" status line always one
set laststatus=2
" always display the tab bar to prevent window resizing when new tabs are created
set showtabline=2

" set up italics
highlight Comment gui=italic

"""""""""""""""""""""""""""""""""""""
"|     PROGRAMMING LANG CONFIGS     |
"""""""""""""""""""""""""""""""""""""

" source file processors
autocmd BufWritePre *.rs,*.c,*.cpp,*.h,*.bat,*.ps1,*.cmd,*.cs,*.csx %s/\s\+$//e

" syntax highlighting
syntax on
au BufReadPost *.txt set syntax=note

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
autocmd FileType gitconfig set noexpandtab shiftwidth=8 softtabstop=0
autocmd BufRead *.csx set syntax=cs

"""""""""""""""""""""""""""""""""""""
"|          NETRW SETTINGS          |
"""""""""""""""""""""""""""""""""""""

" netrw settings:
"   to use tree view
let g:netrw_liststyle = 0
"   no banner
let g:netrw_banner = 1
"   set file open style
let g:netrw_browse_split = 0

" Self-written vim function to find the git root
function! FindGitDirEx(dir)
    if isdirectory(a:dir . "\\.git")
        return a:dir
    endif

    let parent = fnamemodify(a:dir, ':h')
    if parent != a:dir
        return FindGitDirEx(parent)
    endif

    throw "No git dir!"
endfunction

function! FindGitDir()
    echo FindGitDirEx(getcwd())
endfunction

"""""""""""""""""""""""""""""""""""""
"|           COLORS                 |
"""""""""""""""""""""""""""""""""""""
if has('nvim')
    color desert
elseif has('gui_running')
    color desert
else
    set background=dark
    color desert
endif

"""""""""""""""""""""""""""""""""""""
"|          FILE FORMATTING         |
"""""""""""""""""""""""""""""""""""""
" disable vim-markdown autofolding
let g:vim_markdown_folding_disabled = 1 
" don't conceal in markdown mode
let g:vim_markdown_conceal = 0


" use LF line endings by default
set fileformat=unix
set fileformats=unix,dos

" Journal
autocmd VimEnter *.jf call EnterJournal()
function EnterJournal()
    set syn=journal
    $pu=''
    $pu=strftime('[ %a %d %b %y - %X ]')
    normal o
    startinsert!
endfunction

" FOR THE LOVE OF GOD TRY TO GET JSON FILES TO RENDER WITHOUT CONCEALING
set conceallevel=0
