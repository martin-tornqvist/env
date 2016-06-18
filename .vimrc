set nocompatible              " be iMproved, required
filetype off                  " required

" =============================================================================
" set the runtime path to include Vundle and initialize
" Keep Plugin commands between vundle#begin/end!
" =============================================================================
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'rust-lang/rust.vim'

Plugin 'Chiel92/vim-autoformat'

Plugin 'racer-rust/vim-racer'

" NERDTree
Plugin 'https://github.com/scrooloose/nerdtree.git'

" Trailing whitespace
" Fix trailing whitespace with :FixWhitespace
Plugin 'bronson/vim-trailing-whitespace'

" Git stuff
" Reset changes since last commit with :Gread
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

" Aligning text
" Select text, return, space
" E.g. aligning column 2 -> return, 2, space
Plugin 'junegunn/vim-easy-align'

vnoremap <silent> <Enter> :EasyAlign<cr>

" Auto completion
Plugin 'https://github.com/Valloric/YouCompleteMe'

" Airline (status bar)
Plugin 'https://github.com/vim-airline/vim-airline'

" =============================================================================
" Vundle end
" All Plugins must be added before the following line
" =============================================================================
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

" Start NERDTree automatically
autocmd vimenter * NERDTree

" Close Vim if the only window left open is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Show margin line
if (exists('+colorcolumn'))
    set colorcolumn=100
    highlight ColorColumn ctermbg=9
endif

" I dunno? Something needed for YCM
let g:clang_complete_auto = 1
let g:clang_use_library = 1
let g:clang_debug = 1
let g:clang_library_path = '/usr/lib/'
let g:clang_user_options='|| exit 0'

" =============================================================================
" Style configuration
" =============================================================================
set expandtab
set shiftwidth=4
set softtabstop=4
set smartindent
filetype indent on
