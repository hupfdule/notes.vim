let notes#regex#bulletline_base  = '^'                   " At the start of the line
let notes#regex#bulletline_base .= '\s*'                 " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#bulletline_base .= '[\-\*]'              " then either a dash (-) or an asterisk (*)
let notes#regex#bulletline_base .= '\s'                  " a mandatory whitespace character

let notes#regex#bulletline_full  = '^'                   " At the start of the line
let notes#regex#bulletline_full .= '\s*'                 " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#bulletline_full .= '[\-\*]'              " then either a dash (-) or an asterisk (*)
let notes#regex#bulletline_full .= '\s'                  " a mandatory whitespace character
let notes#regex#bulletline_full .= '\('                  " optionally
let notes#regex#bulletline_full .=   '\[[x\ ]\]'         " an empty or filled bracket ([ ] or [x])
let notes#regex#bulletline_full .=   '\s'                " with another mandatory whitespace
let notes#regex#bulletline_full .= '\)\?'

let notes#regex#section_underline  = '^'                 " at the start of the line
let notes#regex#section_underline .= '=\+'               " at least one equals sign (the underline char)
let notes#regex#section_underline .= '\s*'               " and optional whitespace
let notes#regex#section_underline .= '$'                 " until the end of the line
