""
" Jump to the next/previous item of the same level.
"
" "Item" in this context means either a section header or a bullet line.

" {count} specifies the number of items to jump. If there are
" not enough items remaining in the target direction, no jump will
" be done.
"
" If {backwards} is 'v:true' the jump will be made backwards.
"
" @param {count} the number of items to jump (1 to jump to the next item)
" @param {mode} the mode to operate in. May be 'v' for visual mode.
"               Actually other values are not checked. This is only used
"               for reselection of the visual area.
" @param {backwards} if 'v:true' the jump will be executed backwards
"
" TODO: How to test mappings in normal, visual and operator pending mode?
function! notes#motions#jump_to_next_item(count, mode, backwards) abort
  " reselect visual area if we should operate in visual mode
  if a:mode ==# 'v'
    normal! gv
  endif

  let l:flags = ''
  if a:backwards
    let l:flags .= 'b'
  endif

  let l:lnum = line('.')
  for i in range(1, a:count)
    " TODO: Implement the actual seach logic
    " TODO: Differentiate here whether we are on a section heading or a bullet line?
    "       Or can we ignore this and only respect the indent level?
    "let l:lnum = notes#motions#search_item(l:lnum, l:flags)
    " if there aren't enough sections to jump, don't jump at all
    if l:lnum ==# 0
      return
    endif
  endfor

  " Jump to the first column of the target section heading
  call cursor(l:lnum, 1)
endfunction

