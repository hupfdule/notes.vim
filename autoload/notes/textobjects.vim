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
" Text object for bulletlines (including all subitems).
"
" {scope}: i to include the content with all subnodes, but not the bulletline itself
"          a like 'i', but including the bulletline itself
" {visual}: whether this method was called from visual mode (this parameter
"           is actually not used).
function! notes#textobjects#bullet_item(scope, visual) abort
  " FIXME: Wenn der Cursor auf ner leeren Zeile ist, wird der aktuelle
  "        Bulletpunkt "falsch" erkannt. Das Problem ist, dass man den
  "        /nächsten/ Bulletpunkt für das Feststellen des Levels
  "        heranziehen müsste.
  "        Beispiel:
  "          - lorem
  "            - ipsum
  "            - dolores
  "              - mitanes
  "
  "            - valera
  "        Wenn der Cursor in der Zeile /vor/ "valera" steht wird als 'i-'
  "        nur der Punkt "mitanes" erkannt. Erwarten würde man jedoch
  "        "dolores" + "mitanes".
  let l:foldlevel = foldlevel('.')

  if getline('.') =~# s:regex_bulletline
    " if the current line is a bulletline, it is the bulletline we are searching for
    let l:bulletline = line('.')
  else
    " otherwise we search for it backwards
    let l:bulletline = search(s:regex_bulletline, 'Wbn')

    " if there is not bulletline, there is no such textobject
    if l:bulletline is 0
      return
    endif

    let l:foldlevel = foldlevel(l:bulletline)
  endif

  if a:scope ==# 'i'
    if foldlevel(l:bulletline + 1) <=# foldlevel(l:bulletline)
      " if the next line has the same or a lower level, this bulletline
      " doesn't have any content. Therefore ther is no "inner" bulletline
      return
    endif
    let l:start = l:bulletline + 1
  elseif a:scope ==# 'a'
    let l:start = l:bulletline
  else
    throw 'Notes001: Invalid scope: ' . a:scope . '. Only "i" and "a" are supported'
  endif

  " To find the end of the bullet item, search for a line with the same or a lower foldlevel
  let l:end = line('$')
  let l:line = line('.')
  while l:line < line('$')
    let l:line += 1

    " ignore empty lines
    if getline(l:line) =~# '^\s*$'
      continue
    endif

    if foldlevel(l:line) <=# l:foldlevel
      let l:end = l:line - 1
      break
    endif
  endwhile

  echom l:start . ' > ' . l:end
  call cursor(l:start, 0)
  normal! V
  call cursor(l:end, 0)
  normal! $
endfunction


""
" Text object for sections.
"
" {scope}: i to include everything after the section header up to the next
"            section header (or the end of the file).
"          a like 'i', but including section header.
" {visual}: whether this method was called from visual mode (this parameter
"           is actually not used).
function! notes#textobjects#section(scope, visual) abort
  " search the section underline
  if getline('.') =~# s:regex_section_underline
    " if the cursor is on an underline this is the start of the textobject
    let l:prev_underline = line('.')
  elseif getline('.') =~# '^\S\+' && getline(line('.') + 1) =~# s:regex_section_underline
    " if the cursor is on the text of a section heading, the start is its underline
    let l:prev_underline = line('.') + 1
  else
    " else search for it backwards
    let l:prev_underline = search(s:regex_section_underline, 'Wbn')
  endif

  " now search for the end of the section
  " We need to take the start of it into account, since we need to start
  " the search /after/ the underline. If the cursor is on the section
  " headings text, the next underline would be the same as the start of the
  " section
  let l:old_pos = getcurpos()                                    " save cursor position
  call cursor(max([l:prev_underline + 1, line('.')]), 0)         " jump after the starting underline
  let l:next_underline = search(s:regex_section_underline, 'Wn')
  call setpos('.', l:old_pos)                                    " restore cursor position

  if a:scope ==# 'i'
    let l:start = l:prev_underline + 1
  elseif a:scope ==# 'a'
    if l:prev_underline > 1 && getline(l:prev_underline - 1) =~# '^\S\+'
      let l:start = max([1, l:prev_underline - 1])
    else
      " no section heading → no "a section" textobject
      return
    endif
  else
    throw 'Notes001: Invalid scope: ' . a:scope . '. Only "i" and "a" are supported'
  endif

  if l:next_underline is 0
    let l:end = line('$')
  else
    if getline(l:next_underline - 1) =~# '^\S\+'
      let l:end = l:next_underline - 2
    else
      let l:end = l:next_underline - 1
    endif
  endif

  call cursor(l:start, 0)
  normal! V
  call cursor(l:end, 0)
  normal! $
endfunction
