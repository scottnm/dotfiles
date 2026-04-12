" Vim syntax file
" Extension: .note (scratch notes)
" Maintainer: Scott Munro
" Latest Revision: 09 Oct 2019

" Keywords
syn match unansweredQuestion 'Q: .*\n'
syn match answeredQuestion 'Q: .*\nA: .*'
syn match todo 'TODO:'
syn match failed '\[Failed.*$'
syn match error '\[Error.*$'
syn match passed '\[Passed.*$'
syn match info '\[Info\s\+\]'
syn match warning '\[Warning\s\+\]'
syn match trace '\[Trace\s\+\]'
syn match failed '\[E\].*$'
syn match error '\[E\].*$'
syn match passed '\[P\].*$'
syn match info '\[I\].*$'
syn match warning '\[W\].*$'
syn match trace '\[V\].*$'

highlight unansweredQuestion ctermfg=Red guifg=Red
highlight answeredQuestion ctermfg=LightGreen guifg=LightGreen
highlight todo gui=bold ctermfg=Blue guifg=Blue

highlight failed ctermfg=DarkRed guifg=DarkRed
highlight error ctermfg=Red guifg=Red
highlight warning ctermfg=Yellow guifg=Yellow
highlight passed ctermfg=LightGreen guifg=LightGreen
" highlight info ctermfg=White guifg=White
highlight trace ctermfg=DarkYellow guifg=DarkYellow
