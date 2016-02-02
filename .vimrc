" Always start at the top of git commits
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" Enter email messages in insert mode
function STYLE_mhng_comp()
  normal! $
  startinsert
endfunction
au BufNewFile,BufRead /tmp/mhng-comp-*/template.msg call STYLE_mhng_comp()

" This is my style: 4-space indent, no tab characters
function STYLE_mycxx()
  setlocal ts=4
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal filetype=cpp
endfunction

" The style I use for bash
function STYLE_mybash()
  setlocal ts=4
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction

" This is Andrew's style
function STYLE_andrew()
  setlocal ts=2
  set expandtab
  setlocal sw=2
  set smarttab
  set autoindent
endfunction

" My default style for various languages -- these come first, so they can be
" overridden
au BufNewFile,BufRead *.c++ call STYLE_mycxx()
au BufNewFile,BufRead *.h++ call STYLE_mycxx()

au FileType bash call STYLE_mybash()

" Andrew's file needs to be set for some files
au BufNewFile,BufRead /home/palmer/work/*/riscv-pk call STYLE_andrew()
