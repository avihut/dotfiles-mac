set nocompatible
syntax on

source ~/.vim/.plug

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Delete over newlines
set backspace=indent,eol,start

set number
highlight LineNr ctermfg=grey
