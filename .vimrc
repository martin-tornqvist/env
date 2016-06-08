set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Keep Plugin commands between vundle#begin/end.

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'rust-lang/rust.vim'

Plugin 'Chiel92/vim-autoformat'

Plugin 'racer-rust/vim-racer'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Add rustfmt to the list of vim-autoformat formatters
let g:formatdef_rustfmt = '"rustfmt"'
let g:formatters_rust   = ['rustfmt']

" Format on save
au BufWrite * :Autoformat

" Enable racer
set hidden
let g:racer_cmd    = "/home/martin/dev/racer.git/target/release/racer"
let $RUST_SRC_PATH = "/home/martin/dev/rust.git/src/"

" Do not generate backup files
set nobackup

