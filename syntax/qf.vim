if exists("b:current_syntax")
  finish
endif

syntax clear

" syntax match qfError  "\c\<error\>:\@="
" syntax match qfWarn   "\c\<warn\(ing\)\?\>:\@="
" syntax match qfInfo   "\c\<info\>:\@="
" syntax match qfNote   "\c\<\(note\|hint\)\>:\@="
" syntax match qfPassed "\c\<\(ok\|passed\)\>"
" syntax match qfFailed "\c\<\fail\(ed\|ure\)\?s\?\>"

syntax match qfFileName     "^[^: ]*"                       nextgroup=qfLineCol
syntax match qfLineCol      ":\(\d\+:\)\{,2} "  contained

highlight default link  qfFileName      Directory
highlight default link  qfLineCol       Delimiter
highlight default link  qfError         DiagnosticError
highlight default link  qfWarn          DiagnosticWarn
highlight default link  qfInfo          DiagnosticInfo
highlight default link  qfNote          DiagnosticHint
highlight default link  qfPassed        DiagnosticOk
highlight default link  qfFailed        DiagnosticError

highlight clear         QuickFixLine
highlight               QuickFixLine    gui=underline

let b:current_syntax = "qf"
