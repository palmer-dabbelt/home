" Enter email messages in insert mode
function STYLE_mhng_comp()
  normal! $
  startinsert
  setlocal spell
endfunction

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

function STYLE_mylatex()
  setlocal ts=4
  setlocal expandtab
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal filetype=tex
endfunction

function STYLE_mygit()
  setlocal ts=8
  setlocal expandtab
  setlocal tabstop=8
  setlocal shiftwidth=8
  setlocal tw=72
  call setpos('.', [0, 1, 1, 0])
endfunction

" This is Andrew's style
function STYLE_andrew()
  setlocal ts=2
  set expandtab
  setlocal sw=2
  set smarttab
  set autoindent
endfunction

" Editing text files
function STYLE_text()
  setlocal spell
endfunction

" I like to write mail
au BufNewFile,BufRead /tmp/mhng-comp-*/template.msg call STYLE_mhng_comp()

" My default style for various languages -- these come first, so they can be
" overridden
au BufNewFile,BufRead *.c++ call STYLE_mycxx()
au BufNewFile,BufRead *.h++ call STYLE_mycxx()

au BufNewFile,BufRead *.scala call STYLE_andrew()

au FileType bash call STYLE_mybash()

" LaTeX files want a slightly different format
au BufNewFile,BufRead *.tex call STYLE_mylatex()

" Always start at the top of git commits
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call STYLE_mygit()

" Andrew's file needs to be set for some files
au BufNewFile,BufRead /home/palmer/work/*/riscv-pk call STYLE_andrew()

" Text files
au BufNewFile,BufRead *.txt call STYLE_text()
