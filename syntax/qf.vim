if exists('b:current_syntax')
  finish
endif

setlocal conceallevel=2
setlocal concealcursor=nvic

syn match qfUnknown /^. / nextgroup=qfFileName
syn match qfHiddenAll /^   / conceal
syn match qfFileName /[^:]\+/ nextgroup=qfLineNr contained
syn match qfLineNr /:\d\+\(:\d\+\)\?/ contained

call pretty_qf#syntax()

hi def link qfFileName Directory
hi def link qfLineNr   LineNr
hi def link qfError    DiagnosticError
hi def link qfWarning  DiagnosticWarn
hi def link qfHint     DiagnosticHint
hi def link qfInfo     DiagnosticInfo

let b:current_syntax = 'qf'
