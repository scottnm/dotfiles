" Vim syntax file
" Extension: .note (scratch notes)
" Maintainer: Scott Munro
" Latest Revision: 16 May 2018

" Keywords
syn match unansweredQuestion 'Q: .*\n'
syn match answeredQuestion 'Q: .*\nA: .*'
syn match todo 'TODO:'

highlight unansweredQuestion ctermfg=Red guifg=Red
highlight answeredQuestion ctermfg=LightGreen guifg=LightGreen
highlight todo gui=bold ctermfg=Blue guifg=Blue
