let s:expansion_active = 0

function! wincent#autocomplete#setup_mappings() abort
  " Overwrite the mappings that UltiSnips sets up during expansion.
  execute 'inoremap <buffer> <silent> ' . g:UltiSnipsJumpForwardTrigger .
        \ ' <C-R>=wincent#autocomplete#expand_or_jump("N")<CR>'
  execute 'snoremap <buffer> <silent> ' . g:UltiSnipsJumpForwardTrigger .
        \ ' <Esc>:call wincent#autocomplete#expand_or_jump("N")<CR>'
  execute 'inoremap <buffer> <silent> ' . g:UltiSnipsJumpBackwardTrigger .
        \ ' <C-R>=wincent#autocomplete#expand_or_jump("P")<CR>'
  execute 'snoremap <buffer> <silent> ' . g:UltiSnipsJumpBackwardTrigger .
        \ ' <Esc>:call wincent#autocomplete#expand_or_jump("P")<CR>'

  " One additional mapping of our own: accept completion with <CR>.
  imap <expr> <buffer> <silent> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
  smap <expr> <buffer> <silent> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

  let s:expansion_active = 1
endfunction

function! wincent#autocomplete#teardown_mappings() abort
  silent! iunmap <expr> <buffer> <CR>
  silent! sunmap <expr> <buffer> <CR>

  let s:expansion_active = 0
endfunction

let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res = 0
let g:ulti_expand_res = 0

function! wincent#autocomplete#expand_or_jump(direction) abort
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    " No expansion occurred.
    if pumvisible()
      " Pop-up is visible, let's select the next (or previous) completion.
      if a:direction ==# 'N'
        return "\<C-N>"
      else
        return "\<C-P>"
      endif
    else
      if s:expansion_active
        if a:direction ==# 'N'
          call UltiSnips#JumpForwards()
          if g:ulti_jump_forwards_res == 0
            " We did not jump forwards.
            return "\<Tab>"
          endif
        else
          call UltiSnips#JumpBackwards()
        endif
      else
        if a:direction ==# 'N'
          return "\<Tab>"
        endif
      endif
    endif
  endif

  " No popup is visible, a snippet was expanded, or we jumped, or we failed to
  " jump backwards, so nothing to do.
  return ''
endfunction

let s:deoplete_init_done=0
function! wincent#autocomplete#deoplete_init() abort
  if s:deoplete_init_done || !has('nvim')
    return
  endif
  let s:deoplete_init_done=1
  call deoplete#enable()
  call deoplete#custom#source(
        \   'masochist',
        \   'content',
        \   expand('~/code/masochist-pages')
        \ )
  call deoplete#custom#source(
        \   'masochist',
        \   'config',
        \   expand('~/code/masochist/src/server/constants.js')
        \ )
endfunction
