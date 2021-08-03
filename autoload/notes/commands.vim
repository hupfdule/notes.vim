" Regex for identifying a bullet line
let s:regex_bulletline  = '^'                   " At the start of the line
let s:regex_bulletline .= '\s*'                 " an arbitrary number of whitespace (as a bullet line can be indented)
let s:regex_bulletline .= '[\-\*]'              " then either a dash (-) or an asterisk (*)
let s:regex_bulletline .= '\s'                  " a mandatory whitespace character
let s:regex_bulletline .= '\('                  " optionally
let s:regex_bulletline .=   '\[[x\ ]\]'         " an empty or filled bracket ([ ] or [x])
let s:regex_bulletline .=   '\s'                " with another mandatory whitespace
let s:regex_bulletline .= '\)\?'

" FIXME: Can we specify these buffer locally? This would allow such a
"        modline like emacs to define the keywords in the file itself
" TODO:  Allow multiple sets of keywords.
let s:action_keywords = ['TODO', 'WORK', 'DONE', 'CANC']


""
" Select the next/prev action keyword for the current bullet line.
"
" If we are already at the first/last item and select the previous/next one
" the action keyword will be removed.
" If there is no current action keyword and we select the next/previous one
" the first/last one will be selected.

" If {backwards} is 'v:true' the previous keyword will be selected,
" otherwise the next one.
"
" @param {backwards} if 'v:true' the jump will be executed backwards
function! notes#commands#next_action_keyword(backwards) abort
  " Abort if the current line is not a bullet line
  let l:line = getline('.')
  if l:line !~# s:regex_bulletline
    return
  endif

  " Search for the current action keyword
  for keyword in s:action_keywords
    let l:current_keyword = matchstrpos(getline('.'), keyword)
    if l:current_keyword !=# ['', -1, -1]
      break
    endif
  endfor

  " Do the actual replacement/deletion/addition of the action keyword
  if l:current_keyword ==# ['', -1, -1]
    " If no current keyword is found, add the first/last one
    let l:insertpos = matchend(getline('.'), s:regex_bulletline)
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

    echom l:current_keyword[0] . ' ⇒ ' . l:next_keyword
    if l:next_keyword ==# '0'
      " Remove the keyword if it was the last/first one
      let l:new_line = substitute(getline('.'), keyword . '\s\+', '', '')
    else
      " Replace the keyword with the next/prev one
      let l:new_line = substitute(getline('.'), keyword, l:next_keyword, '')
    endif
  endif

  call setline('.', l:new_line)
endfunction
