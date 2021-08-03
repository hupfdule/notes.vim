
if exists("b:current_syntax")
  finish
endif

" FIXME: Das hier ist /viel/ zu langsam. Trennen in zwei Highlights?
"syntax match   notesSectionHeading /\(^\s*$\n\|\%^\|^\[.*\]\s*$\)\@<=\S.*\n[=\-]\+\s*$/
syntax match   notesSectionHeading /^\S.*\n[=\-]\+\s*$/

syntax match   notesBullet         /^\s*\zs\(-\|\*\)\( \[[x\ ]\]\)\?\ze\s/
" FIXME: Wieso klappt das "contained" nicht?
"syntax keyword notesActionTODO     TODO WORK     contained
syntax keyword notesActionTODO     TODO containedin=notesSectionHeading
syntax keyword notesActionWORK     WORK     containedin=notesSectionHeading
syntax keyword notesActionDONE     DONE CANC     containedin=notesBulletLine
syntax cluster notesAction         contains=notesActionTODO,notesActionDONE
"syntax match   notesPrio           /\[#[ABC]\]/  containedin=notesBulletLine,notesBulletLineA
syntax match   notesTag            /:\S\+:$/     containedin=notesBulletLine
syntax match   notesBulletLine     /^\s*\(-\|\*\)\( \[ \]\)\?\s/ contains=notesBullet,@notesAction,notesPrio,notesTag
syntax match   notesBulletLineA    /^\s*\(-\|\*\)\( \[ \]\)\?\s.*\[#A\].*$/ contains=notesBullet,@notesAction,notesPrioA,notesTag
syntax match   notesBulletLineB    /^\s*\(-\|\*\)\( \[ \]\)\?\s.*\[#B\].*$/ contains=notesBullet,@notesAction,notesPrioB,notesTag
syntax match   notesBulletLineC    /^\s*\(-\|\*\)\( \[ \]\)\?\s.*\[#C\].*$/ contains=notesBullet,@notesAction,notesPrioC,notesTag
syntax match   notesPrioA          /\[#A\]/  containedin=notesBulletLine,notesBulletLineA
syntax match   notesPrioB          /\[#B\]/  containedin=notesBulletLine,notesBulletLineB
syntax match   notesPrioC          /\[#C\]/  containedin=notesBulletLine,notesBulletLineC

syntax match   notesBold           /\*\S.\+\*/
syntax match   notesItalic         /\/\S.\+\//
syntax match   notesUnderlined     /_\S.\+_/


" FIXME: Bessere defaults + Extra Unterstützung von gruvbox
highlight notesSectionHeading term=bold      cterm=bold      gui=bold ctermfg=darkyellow   guifg=darkyellow
highlight notesBullet         term=bold      cterm=bold      gui=bold ctermfg=cyan         guifg=cyan
highlight notesActionTODO     term=bold      cterm=bold      gui=bold ctermfg=darkred      guifg=darkred
highlight notesActionWORK     term=bold      cterm=bold      gui=bold ctermfg=red          guifg=red
highlight notesActionDONE     term=bold      cterm=bold      gui=bold ctermfg=green        guifg=green
highlight notesPrioA          term=bold      cterm=bold      gui=bold ctermfg=lightmagenta guifg=lightmagenta
highlight notesPrioB          term=bold      cterm=bold      gui=bold ctermfg=magenta      guifg=magenta
highlight notesPrioC          term=bold      cterm=bold      gui=bold ctermfg=darkmagenta  guifg=darkmagenta
highlight notesTag            term=bold      cterm=bold      gui=bold ctermfg=brown        guifg=brown

highlight notesBold           term=bold      cterm=bold      gui=bold
highlight notesItalic         term=italic    cterm=italic    gui=italic
highlight notesUnderlined     term=underline cterm=underline gui=underline

highlight notesBulletLineA    term=bold      cterm=bold      gui=bold ctermfg=white        guifg=white
highlight notesBulletLineB                                            ctermfg=white        guifg=white
highlight notesBulletLineC                                            ctermfg=gray         guifg=gray
