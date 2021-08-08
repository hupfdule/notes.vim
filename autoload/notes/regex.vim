let notes#regex#bulletline_base  = '^'                     " At the start of the line
let notes#regex#bulletline_base .= '\s*'                   " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#bulletline_base .= '[\-\*]'                " then either a dash (-) or an asterisk (*)
let notes#regex#bulletline_base .= '\s'                    " a mandatory whitespace character

let notes#regex#bulletline_full  = '^'                     " At the start of the line
let notes#regex#bulletline_full .= '\s*'                   " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#bulletline_full .= '[\-\*]'                " then either a dash (-) or an asterisk (*)
let notes#regex#bulletline_full .= '\s'                    " a mandatory whitespace character
let notes#regex#bulletline_full .= '\('                    " optionally
let notes#regex#bulletline_full .=   '\[[x\ ]\]'           " an empty or filled bracket ([ ] or [x])
let notes#regex#bulletline_full .=   '\s'                  " with another mandatory whitespace
let notes#regex#bulletline_full .= '\)\?'

let notes#regex#bulletline_with_tags  = '^'                " At the start of the line
let notes#regex#bulletline_with_tags .= '\s*'              " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#bulletline_with_tags .= '[\-\*]'           " then either a dash (-) or an asterisk (*)
let notes#regex#bulletline_with_tags .= '\s'               " a mandatory whitespace character
let notes#regex#bulletline_with_tags .= '.\{-}'            " any content
let notes#regex#bulletline_with_tags .= '\('               " start capture group 1
let notes#regex#bulletline_with_tags .=   '\s\+'           " at least one whitespace character
let notes#regex#bulletline_with_tags .=   ':\%(\w\+:\)\+'  " followed by some tags (surrounded by colons)
let notes#regex#bulletline_with_tags .= '\)*'              " end capture group 1
let notes#regex#bulletline_with_tags .= '\s*'              " and optional whitespace
let notes#regex#bulletline_with_tags .= '$'                " until the end of the line

let notes#regex#tags_in_bulletline  = '^'                " At the start of the line
let notes#regex#tags_in_bulletline .= '\s*'              " an arbitrary number of whitespace (as a bullet line can be indented)
let notes#regex#tags_in_bulletline .= '[\-\*]'           " then either a dash (-) or an asterisk (*)
let notes#regex#tags_in_bulletline .= '\s'               " a mandatory whitespace character
let notes#regex#tags_in_bulletline .= '.\{-}'            " any content
let notes#regex#tags_in_bulletline .= '\zs'              " match only from here (where the tag begins)
let notes#regex#tags_in_bulletline .=   ':\%(\w\+:\)\+'  " at least one tag (surrounded by colons, separated by colons)
let notes#regex#tags_in_bulletline .= '\ze'              " match ends after the tags
let notes#regex#tags_in_bulletline .= '\s*'              " and optional whitespace
let notes#regex#tags_in_bulletline .= '$'                " until the end of the line


let notes#regex#section_underline  = '^'                   " at the start of the line
let notes#regex#section_underline .= '=\+'                 " at least one equals sign (the underline char)
let notes#regex#section_underline .= '\s*'                 " and optional whitespace
let notes#regex#section_underline .= '$'                   " until the end of the line
