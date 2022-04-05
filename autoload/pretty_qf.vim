let g:pretty_qf_signs_default = {
  \ 'E': 'E',
  \ 'W': 'W',
  \ 'H': 'H',
  \ 'I': 'I'
  \ }

let g:pretty_qf_signs = get(g:, 'pretty_qf_signs', g:pretty_qf_signs_default)
let g:pretty_qf_shorten_path = get(g:, 'pretty_qf_shorten_path', 1)

let s:hidden_sign = '>$<'

function! pretty_qf#quickfixtextfunc(info) abort
  let items = a:info.quickfix
    \ ? getqflist(#{id: a:info.id, items: 1}).items
    \ : getloclist(a:info.winid, #{id: a:info.id, items: 1}).items

  let lines = []
  let pad_len = 0
  let no_sign = 1
  for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
    let item = items[idx]

    let text = trim(item.text)
    if has_key(g:pretty_qf_signs, item.type)
      let no_sign = 0
    endif
    let sign = get(g:pretty_qf_signs, item.type, ' ')

    let filepath = bufname(item.bufnr)->fnamemodify(':p:~:.')

    if g:pretty_qf_shorten_path
      if has('patch-8.2.1741')
        let filepath = pathshorten(filepath, 2)
      else
        let filepath = pathshorten(filepath)
      endif
    endif

    if item.lnum
      let loc = filepath.':'.item.lnum
    else
      let loc = ''
    endif
    if item.col
      let loc = loc.':'.item.col
    endif

    let len = len(loc)
    if len > pad_len
      let pad_len = len
    endif
    let lines = add(lines, #{ sign: sign, loc: loc, text: text })
  endfor
  return map(
    \ lines,
    \ { _, l -> printf('%s %s %s', no_sign ? s:hidden_sign : l.sign, l.loc == '' ? l.loc : pretty_qf#right_pad(l.loc, pad_len), l.text) })
endfunction

function! pretty_qf#right_pad(loc, len) abort
  return a:loc.repeat(' ', a:len - len(a:loc))
endfunction

function! pretty_qf#syntax() abort
  for [type, kind] in
      \ [['E', 'Error'], ['W', 'Warning'], ['H', 'Hint'], ['I', 'Info']]
    if has_key(g:pretty_qf_signs, type)
      execute printf(
        \'syn match qf%s /^%s / nextgroup=qfFileName',
        \ kind, g:pretty_qf_signs[type])
    endif
  endfor
  execute printf('syn match qfHiddenSign /^%s / conceal nextgroup=qfFileName', s:hidden_sign)
  execute printf('syn match qfHiddenSignAndPath /^%s  / conceal', s:hidden_sign)
endfunction
