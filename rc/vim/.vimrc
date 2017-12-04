" Add go packages
filetype off
filetype plugin indent off
set runtimepath+=/usr/lib/go/misc/vim
filetype plugin indent on
syntax on

let g:C_UseTool_cmake = 'yes' 
let g:C_UseTool_doxygen = 'yes' 

set cpoptions+=$
set virtualedit=all
set wildmenu
" Display linenumbers
set number
" Set case insensitive searching
set ic
" Always display at least 6 lines above and below the cursor
set scrolloff=6

" Set tabsize = 4 and various tab options
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
set autoindent

" Map case sensitive commands (because Derp)
:command WQA wqa
:command WQa wqa
:command Wqa wqa
:command WQ wq
:command Wq wq
:command W  w
:command Q  q
:command Qa qa
:command QA qa

" Map F1 to Esc
map <F1> <Esc>
imap <F1> <Esc>
nmap <F1> <Esc>

" YouCompleteMe settings
let g:SuperTabDefaultCompletionType = 'context'

" UltiSnips settings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="horizontal"

" Filetype mappings
au BufNewFile,BufRead *.ino set filetype=cpp
au BufNewFile,BufRead *.tpp set filetype=cpp

" Highlight setyp 
set colorcolumn=80
au BufNewFile,BufRead *.icl set colorcolumn=140
au BufNewFile,BufRead *.html set colorcolumn=120
au BufNewFile,BufRead *.cpp,*.c,*.h,*.hpp set colorcolumn=110
highlight ColorColumn ctermbg=darkgray

" Open h and hpp includes for clang
let &path.="/usr/include/"

" clang options
let g:clang_c_options = '-std=gnu11'
let g:clang_cpp_options = '-std=c++11 -stdlib=libstdc++ -I/usr/include'
let g:clighter_libclang_file = '/usr/lib/llvm-3.6/lib/libclang.so'

" Config make options
set makeprg=make

" Map filesystem
nmap E :E<CR>

" Relative AND absolute line numbers
set relativenumber
set number

" Load plugins
call pathogen#infect()
