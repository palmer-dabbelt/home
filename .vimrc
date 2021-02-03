" Allows me to easily insert git tags into my various files.
command -nargs=1 T r!tag <f-args>
command R T r
command A T a

" Default to a bunch of stuff enabled.
syntax enable
set ai

" Limit git commits to 72 characters
au FileType gitcommit setlocal tw=72
au FileType gitcommit setlocal cc=+1

" Selects between C and C++ by file extension
