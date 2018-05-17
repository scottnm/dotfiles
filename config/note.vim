" Vim syntax file
" Extension: .note (scratch notes)
" Maintainer: Scott Munro
" Latest Revision: 16 May 2018

" Keywords
syn match unansweredQuestion 'Q: \(\w\+\s\?\)\+\n'
syn match answeredQuestion 'Q: \(\w\+\s\?\)\+\nA: \(\w\+\s\?\)\+'
syn match todo 'TODO:'

highlight unansweredQuestion ctermfg=Red guifg=Red
highlight answeredQuestion ctermfg=LightGreen guifg=LightGreen
highlight todo gui=bold ctermfg=Blue guifg=Blue
