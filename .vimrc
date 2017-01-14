set nocompatible
syntax on

source ~/.vim/.plug

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
