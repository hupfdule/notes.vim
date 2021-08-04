" Regex for identifying a bullet line
" FIXME: Should we reuse this regex? Maybe have different regexes for
"        - bulletline (base)
"        - bulletline with checkbox
let s:regex_bulletline  = '^'                   " At the start of the line
let s:regex_bulletline .= '\s*'                 " an arbitrary number of whitespace (as a bullet line can be indented)
let s:regex_bulletline .= '[\-\*]'              " then either a dash (-) or an asterisk (*)
let s:regex_bulletline .= '\s'                  " a mandatory whitespace character

""
" Jump to the next/previous item of the same level.
"
" "Item" in this context means either a section header or a bullet line.
"
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


""
" Get the line number of the next/previous item of the same/lower/higher level.
"
" "Item" in this context means a bullet line.
"
" If {backwards} is 'v:true' the search will be done backwards.
"
" @param {horizontal} if 'v:true' the search will be executed horizontally (search children/parent)
"                     otherwise vertically (search siblings with the same foldlevel)
" @param {backwards} if 'v:true' the search will be executed backwards
"
" @returns the line number of the next sibling or 0 if no such
"          sibling could be found.
function! notes#motions#get_next_bulletline(horizontal, backwards) abort
  let l:search_flags = 'nW'
  if a:backwards
    let l:search_flags .= 'b'
  endif

  let l:target_foldlevel = foldlevel('.')
  " adjust the target foldlevel according to the levelshift
  if a:horizontal
    if a:backwards
      let l:target_foldlevel -= 1
    else
      let l:target_foldlevel += 1
    endif
  endif
  " if the current line is not a bulletline, consider it to belong below
  " the previous bulletline. There we shift the foldlevel for that purpose.
  if l:target_foldlevel > 0 && getline('.') !~# s:regex_bulletline
    let l:target_foldlevel -= 1
  endif

  " remember the current cursor position
  let l:old_pos = getcurpos()
  " now move to the first column to prevent matches in the current line
  call cursor(l:old_pos[1], 1)

  while v:true
    let l:lnum = search(s:regex_bulletline, l:search_flags)
    echom s:regex_bulletline ' . ' l:search_flags . ' ' . ' >> ' . l:lnum
    echom foldlevel(l:lnum) . ' :: ' . l:target_foldlevel

    if l:lnum ==# 0
      " if there is not search result anymore, there is no matching line
      break
    elseif l:lnum !=# 0 && foldlevel(l:lnum) ==# l:target_foldlevel
      " if there is a match and its foldlevel matches the current foldlevel,
      " we found the match
      break
    else
      " otherwise (matching line, different foldlevel) we search again from
      " the position
      call cursor(l:lnum, 1)
    endif
  endwhile

  " restore the original cursor position
  call setpos('.', l:old_pos)

  return l:lnum
endfunction
