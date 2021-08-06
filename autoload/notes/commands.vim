
" FIXME: Can we specify these buffer locally? This would allow such a
"        modline like emacs to define the keywords in the file itself
" TODO:  Allow multiple sets of keywords.
let s:action_keywords = ['TODO', 'WORK', 'DONE', 'CANC']

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
  if l:line !~# g:notes#regex#bulletline
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
    let l:insertpos = matchend(getline('.'), g:notes#regex#bulletline)
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
  if l:line !~# g:notes#regex#bulletline
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
    let l:insertpos = matchend(getline('.'), g:notes#regex#bulletline)
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
" If the current line already is a section heading, its underline is
" adjusted to the same length as the section heading text.
"
" If the current line already is a section heading with a an underline that
" matches the length of the section heading text, the underline is removed.
" FIXME: Really do this?
"
" If the current line is a bullet line, this does nothing.
function! notes#commands#add_section() abort

endfunction
