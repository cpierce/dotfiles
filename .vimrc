" break with the busted old vi junk
" must be first
set nocompatible
filetype off

" vim plug install if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Plugins
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'liuchengxu/vista.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'godlygeek/tabular'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'mbbill/undotree'
Plug 'nanotech/jellybeans.vim'
Plug 'plasticboy/vim-markdown'
Plug 'derekwyatt/vim-scala'
Plug 'juliosueiras/vim-terraform-completion'

call plug#end()

" Make undo work across coding sessions
if !(isdirectory($HOME . '/.vim/undodir'))
    call mkdir($HOME . '/.vim/undodir', 'p')
endif
set undofile
set undodir=~/.vim/undodir

" some random settings
set encoding=utf-8
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
endif

" SASS Syntax Compiler
autocmd FileType scss nnoremap ,m :w <BAR> !sass %:%:r.css<CR><space>

" Airline Show
set laststatus=2
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#buffers#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'jellybeans'
let g:airline_symbols.space = "\ua0"
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#left_sep = ''

""""""""""""""""""""""""""""""""""""""""
" General VIM
""""""""""""""""""""""""""""""""""""""""

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" show lines in lower right
set ruler

" Enable mouse support
set mouse=a

" don't wrap lines ever
set nowrap

" Set to auto read when a file is changed from the outside
set autoread

" global text columns
set textwidth=78

" don't automatically break long lines unless they are new
set formatoptions+=l

" detect file type, turn on that type's plugins and indent preferences
filetype plugin indent on

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" This disables a beep on => and -> in PHP
autocmd BufWinEnter *.php set mps-=<:>

" allow background buffers
set hidden

" global tab settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab

" ignore these nonsense files
set wildignore=*.swp,*.bak,*.pyc,*.class

" Return to last edit position when opening files
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

" Auto format file on save
autocmd BufWritePre * :%s/\s\+$//e

" Write file using sudo if :w!! is called
cmap w!! %!sudo tee > /dev/null %

" Remember info about open buffers on close
set viminfo^=%

" no backups, please!
set nobackup
set noswapfile

" keep a longer history
set history=1000

" enable folding
set foldmethod=indent
set foldlevel=99

" make file/command tab completion useful
set wildmode=list:longest

" clipboard fusion!
set clipboard=unnamed clipboard^=unnamedplus

" Source the vimrc file after saving it.
" This way, you don't have to reload Vim to see the changes.
if has("autocmd")
    augroup myvimrchooks
        au!
        autocmd bufwritepost .vimrc source ~/.vimrc
    augroup END
endif

" No arrow keys!
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

" Format file by shortcut key
function! FormatFile()
    :normal gg=G
endfunc

" Relative numbers by default
set number
set relativenumber

""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""

" set leader to comma key
let mapleader = ","

" Tab magic
nnoremap <tab><tab> :tabn<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>to :tabonly<CR>

" Undo magic
let g:undotree_WindowLayout = 3 " Place on the right
nnoremap <leader>u :UndotreeToggle<CR>

" format file
nnoremap <leader>F :call FormatFile()<CR>

" Unisnip
"let g:SnipsExpandTrigger="<Tab>"
"let g:SnipsJumpForwardTrigger="<Tab>"
"let g:SnipsJumpBackwardTrigger="<S-Tab>"

" fzf config
set rtp+=/opt/homebrew/opt/fzf
nnoremap <leader>n :Files<cr>
nnoremap <leader>vs :vertical split \| :Files<CR>
nnoremap <leader>hs :split \| :Files<CR>
nnoremap <leader>tn :tabnew \| :Files<CR>
nnoremap <leader>bb :Buffers<CR>

nnoremap <leader>f :BLines<CR>

" switch between files with <leader><leader>
nnoremap <leader><leader> <c-^>

" easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
nmap <C-s> :write<CR>

" Remap VIM 0 to first non-blank character
map 0 ^

" set exit insert mode to jj
imap jj <Esc>

" reselect when indenting
vnoremap < <gv
vnoremap > >gv

" leader commands
nnoremap <leader>i :PlugInstall!<cr>

" /// for vim-commentary
nmap /// <Plug>CommentaryLine

""""""""""""""""""""""""""""""""""""""""
" Searching
""""""""""""""""""""""""""""""""""""""""

" show search matches as you type
set incsearch

" clear the search buffer when hitting return
nnoremap <CR> :nohlsearch<cr>

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" highlight search results
set hlsearch

""""""""""""""""""""""""""""""""""""""""
" Aesthetics
""""""""""""""""""""""""""""""""""""""""

" keep cursor somewhat centered
set scrolloff=10

" highlight current line
:set cursorline

" invert and bold status line
set highlight=sbr

" enable syntax highlighting
syntax on

"tell the term has 256 colors
set t_Co=256

set background=dark
colorscheme jellybeans

" highlight col 80
set colorcolumn=80

" extra whitespace sucks, make it RED
highlight ExtraWhitespace ctermbg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red
match ExtraWhitespace /\s\+$/