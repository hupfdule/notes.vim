""
" Apply the given fold operation to the line /below/ the current one.
"
" This is useful for folds where the current line is not considered part of
" the fold by vim, but would usually by the user. For example with
" foldmethod=indent and the cursor is the line /above/ a fold, the fold
" operation would be executed /inside/ the fold.
"
" If the line below the current one doesn't have a deeper foldlevel than
" the current line, execute the fold operation on the current line instead.
"
" This method is intended to be used in mappings for fold operations, like
" 'zo', 'zc', etc. The argument 'fold_operation' should normally have the
" same value as the lhs of the mapping.
"
" @param {fold_operation} the fold operation to execute
function! notes#folding#apply_fold_operation(fold_operation) abort
  echom  foldlevel(line('.')) . ' :: ' .  foldlevel(line('.') + 1)
  if foldlevel(line('.')) < foldlevel(line('.') + 1)
    return 'j' . a:fold_operation . 'k'
  else
    return a:fold_operation
  endif
endfunction


