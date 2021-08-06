" Regex for identifying a bullet line
" FIXME: Should we reuse this regex? Maybe have different regexes for
"        - bulletline (base)
"        - bulletline with checkbox
let s:regex_bulletline  = '^'                   " At the start of the line
let s:regex_bulletline .= '\s*'                 " an arbitrary number of whitespace (as a bullet line can be indented)
let s:regex_bulletline .= '[\-\*]'              " then either a dash (-) or an asterisk (*)
let s:regex_bulletline .= '\s'                  " a mandatory whitespace character

let s:regex_section_underline  = '^'                 " at the start of the line
let s:regex_section_underline .= '=\+'               " at least one equals sign (the underline char)
let s:regex_section_underline .= '\s*'               " and optional whitespace
let s:regex_section_underline .= '$'                 " until the end of the line

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
function! notes#motions#jump_to_next_item(count, mode, horizontal, backwards) abort
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
    if !a:horizontal && (getline('.') =~# s:regex_section_underline || getline(line('.') + 1) =~# s:regex_section_underline)
      " search for section headings only vertically
      let l:lnum = notes#motions#get_next_section_heading(a:backwards)
    else
      let l:lnum = notes#motions#get_next_bulletline(a:horizontal, a:backwards)
      " if we are searching for the next higher level and there is no more
      " bullet line, try to find the previous section heading
      if l:lnum is 0 && a:horizontal && a:backwards
        let l:lnum = notes#motions#get_next_section_heading(a:backwards)
      endif
    endif
    " if there aren't enough items to jump to, don't jump at all
    if l:lnum ==# 0
      return
    endif
  endfor

  " get the difference between the line numbers
  let l:lnum_diff = abs(line('.') - l:lnum)

  " Jump to the first column of the target section heading
  " We use 'j' and 'k' here to retain the cursor position even for
  " subsequent jumps.
  let l:direction = a:backwards ? 'k' : 'j'
  execute 'normal! ' . string(l:lnum_diff) . l:direction
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

  let l:current_foldlevel = foldlevel('.')
  let l:target_foldlevel = l:current_foldlevel
  " adjust the target foldlevel according to the levelshift
  if a:horizontal
    if a:backwards
      let l:target_foldlevel -= 1
    else
      let l:target_foldlevel += 1
    endif
  endif
  " if the current line is not a bulletline and not a section heading, consider it to belong below
  " the previous bulletline. Therefore we shift the foldlevel for that purpose.
  if l:target_foldlevel > 0
      \ && getline('.') !~# s:regex_bulletline
      \ && getline('.') !~# s:regex_section_underline
      \ && getline(line('.') + 1) !~# s:regex_section_underline
    let l:target_foldlevel -= 1
  endif

  " remember the current cursor position
  let l:old_pos = getcurpos()
  " now move to the first column to prevent matches in the current line
  call cursor(l:old_pos[1], 1)

  while v:true
    let l:lnum = search(s:regex_bulletline, l:search_flags)

    if l:lnum ==# 0
      " if there is not search result anymore, there is no matching line
      break
    elseif a:horizontal && !a:backwards && l:lnum !=# 0 && foldlevel(l:lnum) ==# l:current_foldlevel
      " When searching for deeper items: if there is a match with /the same/
      " foldlevel, stop searching.  There are no more subitems then.
      let l:lnum = 0
      break
    elseif !a:horizontal && l:lnum !=# 0 && foldlevel(l:lnum) <# l:target_foldlevel
      " When searching for items in the same level, don't jump across
      " parent items
      let l:lnum = 0
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


""
" Get the line number of the next/previous section heading.
"
" If {backwards} is 'v:true' the search will be done backwards.
"
" @param {backwards} if 'v:true' the search will be executed backwards
"
" @returns the line number of the underline of the next section headingi
"          or 0 if no further section heading could be found.
function! notes#motions#get_next_section_heading(backwards) abort
  let l:search_flags = 'nW'
  if a:backwards
    let l:search_flags .= 'b'
  endif

  let l:old_pos = getcurpos()

  " If we are the text /above/ the underline, we need to start searching
  " /after/ that underline.
  if getline(line('.') + 1) =~# s:regex_section_underline
    call cursor(line('.') + 1, 0)
  endif

  let l:lnum = search(s:regex_section_underline, l:search_flags)

  call setpos('.', l:old_pos)

  return l:lnum
endfunction
