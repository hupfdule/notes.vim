" Vim filetype plugin for Notes files
" Language:     Notes
" Maintainer:   Marco Herrn <marco@mherrn.de>
" Last Changed: 02. August 2021
" URL:          http://github.com/hupfdule/notes.vim
" License:      MIT

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Options ================================================================ {{{

  ""
  " Whether to enable mappings (default 1)
  if !exists('g:notes_enable_mappings')
    let g:notes_enable_mappings = 1
  endif

  ""
  " How to align tags when reformatting lines (default 'left')
  "
  " May be set to 'left' or 'right'.
  "
  if !exists('g:notes_reformat_tags_alignment')
    let g:notes_reformat_tags_alignment = 'left'
  endif

" END Options ============================================================ }}}

" Settings =============================================================== {{{
  " Prepare undo_ftplugin to unset all settings on ft switch
  if !exists('b:undo_ftplugin')
    " simply unlet a dummy variable (idea taken from Colorizer.vim)
    let b:undo_ftplugin = "unlet! b:notes_foobar"
  endif

  " Foldemethod indent should be enough since indentation is the main
  " structuring element.
  " Only drawback is that leading and trailing empty lines are not folded as well
  setlocal foldmethod=indent
  let b:undo_ftplugin .= "| setlocal foldmethod<"

" Commands =============================================================== {{{

  " Navigation ----------------------------------------------------------- {{{

    " Jump between adjacent section headings
    nnoremap <buffer> <Plug>(NotesNextItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'n', v:false, v:false)<cr>
    onoremap <buffer> <Plug>(NotesNextItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'o', v:false, v:false)<cr>
    xnoremap <buffer> <Plug>(NotesNextItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'v', v:false, v:false)<cr>
    nnoremap <buffer> <Plug>(NotesPrevItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'n', v:false, v:true)<cr>
    onoremap <buffer> <Plug>(NotesPrevItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'o', v:false, v:true)<cr>
    xnoremap <buffer> <Plug>(NotesPrevItem)       :<c-u>call notes#motions#jump_to_next_item(v:count1, 'v', v:false, v:true)<cr>
    nnoremap <buffer> <Plug>(NotesNextDeeperItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'n', v:true,  v:false)<cr>
    onoremap <buffer> <Plug>(NotesNextDeeperItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'o', v:true,  v:false)<cr>
    xnoremap <buffer> <Plug>(NotesNextDeeperItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'v', v:true,  v:false)<cr>
    nnoremap <buffer> <Plug>(NotesNextHigherItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'n', v:true,  v:true)<cr>
    onoremap <buffer> <Plug>(NotesNextHigherItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'o', v:true,  v:true)<cr>
    xnoremap <buffer> <Plug>(NotesNextHigherItem) :<c-u>call notes#motions#jump_to_next_item(v:count1, 'v', v:true,  v:true)<cr>
    " TODO: Allow disabling of mappings
    nmap <buffer> ]] <Plug>(NotesNextItem)
    omap <buffer> ]] <Plug>(NotesNextItem)
    xmap <buffer> ]] <Plug>(NotesNextItem)
    nmap <buffer> [[ <Plug>(NotesPrevItem)
    omap <buffer> [[ <Plug>(NotesPrevItem)
    xmap <buffer> [[ <Plug>(NotesPrevItem)
    nmap <buffer> ]} <Plug>(NotesNextDeeperItem)
    omap <buffer> ]} <Plug>(NotesNextDeeperItem)
    xmap <buffer> ]} <Plug>(NotesNextDeeperItem)
    nmap <buffer> [{ <Plug>(NotesNextHigherItem)
    omap <buffer> [{ <Plug>(NotesNextHigherItem)
    xmap <buffer> [{ <Plug>(NotesNextHigherItem)

  " END Navigation }}}

  " Folding -------------------------------------------------------------- {{{

    nnoremap <expr> zo notes#folding#apply_fold_operation('zo')
    nnoremap <expr> zO notes#folding#apply_fold_operation('zO')
    nnoremap <expr> zc notes#folding#apply_fold_operation('zc')
    nnoremap <expr> zC notes#folding#apply_fold_operation('zC')
    nnoremap <expr> za notes#folding#apply_fold_operation('za')
    nnoremap <expr> zA notes#folding#apply_fold_operation('zA')

  " END Folding }}}

  " Editing -------------------------------------------------------------- {{{

    nnoremap <buffer> <Plug>(NotesNextActionKeyword) :call notes#commands#next_action_keyword(v:false)<cr>
    nnoremap <buffer> <Plug>(NotesPrevActionKeyword) :call notes#commands#next_action_keyword(v:true)<cr>
    " TODO: Allow disabling of mappings
    nmap <buffer> <S-Right> <Plug>(NotesNextActionKeyword)
    nmap <buffer> <S-Left>  <Plug>(NotesPrevActionKeyword)

    nnoremap <buffer> <Plug>(NotesNextPrio) :call notes#commands#next_priority(v:false)<cr>
    nnoremap <buffer> <Plug>(NotesPrevPrio) :call notes#commands#next_priority(v:true)<cr>
    " TODO: Allow disabling of mappings
    nmap <buffer> <S-Up>    <Plug>(NotesNextPrio)
    nmap <buffer> <S-Down>  <Plug>(NotesPrevPrio)

    nnoremap <buffer> <Plug>(NotesAddSection) :call notes#commands#add_section()<cr>
    " TODO: Allow disabling of mappings
    nmap <buffer> g= <Plug>(NotesAddSection)

    nnoremap <buffer> <Plug>(NotesReformatLine) :set opfunc=notes#commands#reformat_lines<CR>g@
    xnoremap <buffer> <Plug>(NotesReformatLine) :call notes#commands#reformat_lines('')<cr>
    " TODO: Allow disabling of mappings
    nmap <buffer> g: <Plug>(NotesReformatLine)
    xmap <buffer> g: <Plug>(NotesReformatLine)

  " END Editing }}}

  " Help ----------------------------------------------------------------- {{{
    command! -buffer         NotesHelp   call notes#help#syntax()
    nnoremap <buffer> <Plug>(NotesHelp)  :NotesHelp<cr>
    nmap                             g?  <Plug>(NotesHelp)
  " END Help }}}

" END Commands }}}

" Text objects =========================================================== {{{

  xnoremap <buffer> <silent> i= :<C-U>call notes#textobjects#section('i', v:true)<CR>
  onoremap <buffer> <silent> i= :<C-U>call notes#textobjects#section('i', v:false)<CR>
  xnoremap <buffer> <silent> a= :<C-U>call notes#textobjects#section('a', v:true)<CR>
  onoremap <buffer> <silent> a= :<C-U>call notes#textobjects#section('a', v:false)<CR>

  xnoremap <buffer> <silent> i- :<C-U>call notes#textobjects#bullet_item('i', v:true)<CR>
  onoremap <buffer> <silent> i- :<C-U>call notes#textobjects#bullet_item('i', v:false)<CR>
  xnoremap <buffer> <silent> a- :<C-U>call notes#textobjects#bullet_item('a', v:true)<CR>
  onoremap <buffer> <silent> a- :<C-U>call notes#textobjects#bullet_item('a', v:false)<CR>

  xnoremap <buffer> <silent> i: :<C-U>call notes#textobjects#tags('i', v:true)<CR>
  onoremap <buffer> <silent> i: :<C-U>call notes#textobjects#tags('i', v:false)<CR>
  xnoremap <buffer> <silent> a: :<C-U>call notes#textobjects#tags('a', v:true)<CR>
  onoremap <buffer> <silent> a: :<C-U>call notes#textobjects#tags('a', v:false)<CR>

" END Text objects }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set fdm=marker :
