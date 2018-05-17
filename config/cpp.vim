" Vim syntax file
" Language: Bumblelion CPP
" Maintainer: Scott Munro
" Latest Revision: 2 May 2018

syn match OtherMacros '\<[A-Z_]\+\>'
syn match ReturnMacros '\<\([A-Z]\+_\)\?RETURN\(_[A-Z]\+\)*\>'
syn match DbgStatements 'Dbg\([A-Z][a-z]\+\)\+'
syn match NamedConstants '\<c_[a-z]\w\+\>'

hi link OtherMacros PreProc
hi link ReturnMacros Statement
hi link DbgStatements PreProc
hi link NamedConstants Constant
