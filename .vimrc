set nocompatible
syntax on

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
source ~/.vim/.plug

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Delete over newlines
set backspace=indent,eol,start

set number
highlight LineNr ctermfg=grey

let g:ackprg = 'ag --nogroup --nocolor --column'

map <Tab> <C-W>w
map <S-Tab> <C-W>W

set incsearch
set hlsearch
