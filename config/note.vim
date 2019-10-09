" Vim syntax file
" Extension: .note (scratch notes)
" Maintainer: Scott Munro
" Latest Revision: 09 Oct 2019

" Keywords
syn match unansweredQuestion 'Q: .*\n'
syn match answeredQuestion 'Q: .*\nA: .*'
syn match todo 'TODO:'
syn match failed '\[Failed.*$'
syn match passed '\[Passed.*$'
syn match info '\[Info\s\+\]'
syn match warning '\[Warning\s\+\]'

highlight unansweredQuestion ctermfg=Red guifg=Red
highlight answeredQuestion ctermfg=LightGreen guifg=LightGreen
highlight todo gui=bold ctermfg=Blue guifg=Blue

highlight failed ctermfg=Red guifg=Red
highlight warning ctermfg=Red guifg=Red
highlight passed ctermfg=LightGreen guifg=LightGreen
highlight info ctermfg=Yellow guifg=Yellow
