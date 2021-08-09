
" FIXME: Can we specify these buffer locally? This would allow such a
"        modline like emacs to define the keywords in the file itself
" TODO:  Allow multiple sets of keywords.
let s:action_keywords = ['TODO', 'WORK', 'HOLD', 'FDBK', 'DONE', 'CANC']

let s:priorities = ['[#C]', '[#B]', '[#A]']

""
" Select the next/prev action keyword for the current bullet line.
"
" If we are already at the first/last item and select the previous/next one
" the action keyword will be removed.
" If there is no current action keyword and we select the next/previous one
" the first/last one will be selected.
"
" If {backwards} is 'v:true' the previous keyword will be selected,
" otherwise the next one.
"
" @param {backwards} if 'v:true' the jump will be executed backwards
function! notes#commands#next_action_keyword(backwards) abort
  " Abort if the current line is not a bullet line
  let l:line = getline('.')
  if l:line !~# g:notes#regex#bulletline_full
    return
  endif

  " Search for the current priority
  for keyword in s:action_keywords
    let l:current_keyword = matchstrpos(getline('.'), keyword)
    if l:current_keyword !=# ['', -1, -1]
      break
    endif
  endfor

  " Do the actual replacement/deletion/addition of the action keyword
  if l:current_keyword ==# ['', -1, -1]
    " If no current keyword is found, add the first/last one
    let l:insertpos = matchend(getline('.'), g:notes#regex#bulletline_full)
    let l:next_keyword = get(s:action_keywords, (a:backwards ? -1 : 0))
    let l:new_line = getline('.')[0:l:insertpos-1] . l:next_keyword . ' ' . getline('.')[l:insertpos:]
  else
    " Otherwise select the next one
    let l:current_keyword_idx = index(s:action_keywords, l:current_keyword[0])
    if a:backwards && l:current_keyword_idx == 0
      let l:next_keyword = 0
    elseif !a:backwards && l:current_keyword_idx == len(s:action_keywords)-1
      let l:next_keyword = 0
    else
      let l:next_keyword = get(s:action_keywords, l:current_keyword_idx + (a:backwards ? -1 : 1))
    endif

    if l:next_keyword is 0
      " Remove the keyword if it was the last/first one
      let l:new_line = substitute(getline('.'), keyword . '\s\+', '', '')
    else
      " Replace the keyword with the next/prev one
      let l:new_line = substitute(getline('.'), keyword, l:next_keyword, '')
    endif
  endif

  call setline('.', l:new_line)
endfunction


""
" Select the next higher/lower priority for the current bullet line.
"
" If we are already at the lowest/highest priority and select the next
" lower/higher one the priority will be removed.
" If there is no current priority and we select the next higher/lower one
" the loest/highest one will be selected.
"
" If {backwards} is 'v:true' the next lower priority will be selected,
" otherwise the next higher one.
"
" @param {backwards} if 'v:true' the jump will be executed backwards
function! notes#commands#next_priority(backwards) abort
  " Abort if the current line is not a bullet line
  let l:line = getline('.')
  if l:line !~# g:notes#regex#bulletline_full
    return
  endif

  " Search for the current priority
  for prio in s:priorities
    let l:current_prio = matchstrpos(getline('.'), escape(prio, '[]'))
    if l:current_prio !=# ['', -1, -1]
      break
    endif
  endfor

  " Do the actual replacement/deletion/addition of the priority
  if l:current_prio ==# ['', -1, -1]
    " If no current priority is found, add the lowest/highest one
    " Inser the prio either directly after the bullet point or after the
    " action keyword (if any exists)
    let l:insertpos = matchend(getline('.'), g:notes#regex#bulletline_full)
    for keyword in s:action_keywords
      let l:insertpos2 = matchend(getline('.'),  '^\s*' . keyword . '\s*', l:insertpos)
      if l:insertpos2 > -1
         let l:insertpos = l:insertpos2
         break
      endif
    endfor

    let l:next_prio = get(s:priorities, (a:backwards ? -1 : 0))
    let l:new_line = getline('.')[0:l:insertpos-1] . l:next_prio . ' ' . getline('.')[l:insertpos:]
  else
    " Otherwise select the next one
    let l:current_prio_idx = index(s:priorities, l:current_prio[0])
    if a:backwards && l:current_prio_idx == 0
      let l:next_prio = 0
    elseif !a:backwards && l:current_prio_idx == len(s:priorities)-1
      let l:next_prio = 0
    else
      let l:next_prio = get(s:priorities, l:current_prio_idx + (a:backwards ? -1 : 1))
    endif

    if l:next_prio is 0
      " Remove the prio if it was the highest/lowest one
      let l:new_line = substitute(getline('.'), escape(prio, '[]'). '\s\+', '', '')
    else
      " Replace the prio with the next higher/lower one
      let l:new_line = substitute(getline('.'), escape(prio, '[]'), l:next_prio, '')
    endif
  endif

  call setline('.', l:new_line)
endfunction


""
" Converts the current line to a section heading.
"
" If the current line contains text and is not underlined with a section
" underline, this underline is added.
"
" If the current line already is a section heading (either the text or the
" underline), its underline is adjusted to the same length as the section
" heading text.
"
" If the current line already is a section heading (either the text or the
" underline) with a an underline that matches the length of the section
" heading text, the underline is removed.
"
" If the current line is a bullet line, this does nothing.
function! notes#commands#add_section() abort
  " do nothing on bullet lines
  if getline('.') =~# g:notes#regex#bulletline_base
    return
  endif

  " do nothing if the current line is not a valid section heading
  if getline('.') !~# '^\S'
    return
  endif

  " if this is not a section heading…
  " FIXME: Move this regex for valid section heading text (non-whitespace
  " at the first position into the regex.vim autoload file? Would be
  " better. We could also include a check for disallowing bullets)
  if getline('.') !~# g:notes#regex#section_underline && getline(line('.') + 1) !~# g:notes#regex#section_underline
    "… convert it to a section heading by adding an underline
    normal! yypVr=
  " if this is the underline of a section heading…
  elseif getline('.') =~# g:notes#regex#section_underline
    "…and has a differnt length than its heading
    if s:line_length_differs(line('.') - 1, line('.'))
      "…correct the length of the underline
      normal! kyyjVpVr=
    else
      "…otherwise remove the underline
      normal! ddk
    endif
  " if this is the text of a section heading…
  elseif getline(line('.') + 1) =~# g:notes#regex#section_underline
    "…and has a differnt length than its underline
    if s:line_length_differs(line('.'), line('.') + 1)
      "…correct the length of the underline
      normal! yyjVpVr=
    else
      "…otherwise remove the underline
      normal! jddk
    endif
  endif
endfunction

""
" Checks whether two lines have the same length
"
" @param {lnum1} the line number of the first line to check
" @param {lnum2} the line number of the second line to check
"
" @returns 1 if the length of {lnum1} and {lnum2} differs, otherwise 0.
function! s:line_length_differs(lnum1, lnum2) abort
  return len(getline(a:lnum1)) !=# len(getline(a:lnum2))
endfunction

""
" Reformat the lines specified via a range or the current line if no range
" was given.
"
" See @link(notes#commands#reformat_line) for details about the actual
" functionality.
function! notes#commands#reformat_lines(motion_type) range abort
  if a:motion_type == ''
    let l:firstline = a:firstline
    let l:lastline  = a:lastline
  else
    let l:firstline = line('''[')
    let l:lastline  = line(''']')
  endif
  for l:lnum in range(l:firstline, l:lastline)
    call notes#commands#reformat_line(l:lnum)
  endfor
endfunction

""
" Reformat a line to the default.
"
" The following formattings are applied:
"
" - [x] Push the tags to the right up to 'textwidth' or 100 if 'textwidth'
"       is not set
" - [ ] Fix indentations to multiples of 'shiftwidth'
" - [ ] Reduce multipe whitespace characters around action keywords and
"       priorities to a single space
"
" @parameter {lnum} the line to reformat
function! notes#commands#reformat_line(lnum) range abort
  " push tags to right-align with 'textwidth'
  let l:line = getline(a:lnum)
  let l:tags_part = matchlist(l:line, g:notes#regex#bulletline_with_tags)

  if l:tags_part !=# [] && l:tags_part[1] != ''
    let l:textwidth = &textwidth
    if l:textwidth ==# 0
      let l:textwidth = 100
    endif

    " remove all surrounding whitespace from the actual tags
    let l:tags = trim(l:tags_part[1])
    " find the end of the bulletlines text (before the tags)
    " FIXME: Das hier haut nicht immer hin
    let l:end_of_bulletline = strridx(l:tags_part[0], l:tags_part[1]) - 1
    " We need to get the byte index. Otherwise we get a wrong result
    let l:end_of_bulletline = charidx(l:tags_part[0], l:end_of_bulletline)
    " calculate the correct amout of spaces to push the tags up to 'textwidth'
    if get(g:, 'notes_reformat_tags_alignment', 'left') ==# 'right'
      " right align if requested
      let l:no_of_spaces = l:textwidth - len(l:tags) - l:end_of_bulletline - 1
    else
      " left align in all other cases (even invalid values of g:notes_reformat_tags_alignment)
      let l:no_of_spaces = l:textwidth - l:end_of_bulletline - 2
    endif
    let l:no_of_spaces = max([1, l:no_of_spaces])
    let l:new_tags_part = repeat(' ', l:no_of_spaces) . l:tags
    " prepare the new bulletline
    let l:new_line = substitute(l:line, l:tags_part[1], l:new_tags_part, '')
    " strip any trailing whitespace from the new bulletline
    let l:new_line = substitute(l:new_line, '\s\+$', '', '')

    call setline(a:lnum, l:new_line)
  endif
endfunction
