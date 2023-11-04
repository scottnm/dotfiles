
" Neovim decided not to support the old 'gui_running' flag so use my own flag
" to determine the presence of a gui window
let g:in_gui_window = has('gui_running') || exists('g:neovide') || exists('g:GuiLoaded')

set noerrorbells

"        GUI CONFIG        "
if has('nvim')
    set guifont=Cascadia\ Mono:h8
else " windows
    if has('unix')
        set guifont=Cascadia\ Mono\ 11
    else " windows
        set guifont=Cascadia\ Mono:h11
    endif
endif
if has('gui_running')
    set lines=40 columns=125
    winpos 300 300
endif
set visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=
set guioptions-=r " prevent window movement when vsplit
set guioptions-=L " prevent window movement when vsplit

if has('nvim') || g:in_gui_window
    color lucius
    set background=dark
endif
