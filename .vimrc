" break with the busted old vi junk
" must be first
set nocompatible
filetype off

""""""""""""""""""""""""""""""""""""""""
" Bundles
""""""""""""""""""""""""""""""""""""""""

" vundle stuff
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

" Vundle Plugins
Plugin 'gmarik/vundle'
Plugin 'bufkill.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-commentary'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tobys/vmustache'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-surround'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-fugitive'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'godlygeek/tabular'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'airblade/vim-gitgutter'
Plugin 'tobyS/pdv'
Plugin 'brookhong/dbgpavim'
Plugin 'mbbill/undotree'

Plugin 'nanotech/jellybeans.vim'

Plugin 'pearofducks/ansible-vim'
Plugin 'kylef/apiblueprint.vim'
Plugin 'kchmck/vim-coffee-script'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'othree/html5.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'plasticboy/vim-markdown'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'derekwyatt/vim-scala'

" Make undo work across coding sessions
set undofile
set undodir=~/.vim/undodir

" XDebug connection from vagrant to local
let g:dbgPavimPathMap = [['.', '/vagrant'],]

" NERDTree options
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let g:NERDTreeWinPos = "right"

" some random settings
set encoding=utf-8

" custom file ignores
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\.vagrant$\|\.git$\|\.hg$\|\.svn$\|bower_components$\|dist$\|node_modules$\|project_files$\|test$',
            \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

let g:ctrlp_use_caching = 0
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor

    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
else
    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
    let g:ctrlp_prompt_mappings = {
                \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
                \ }
endif

" LESS Syntax
nnoremap ,m :w <BAR> !lessc % > %:t:r.css<CR><space>

" Airline show
set laststatus=2
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
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

" set leader
let mapleader = ","

" Undo magic
nnoremap <leader>u :call UndotreeToggle()<CR>

" format file
nnoremap <leader>F :call FormatFile()<CR>

" Unisnip
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"

" PDV config
let g:pdv_template_dir = $HOME ."/.vim/bundle/pdv/templates_snip"
nnoremap <leader>/ :call pdv#DocumentWithSnip()<CR>

" toggle NERDTree with leader + n
nnoremap <leader>n :NERDTreeToggle<CR>

" switch between files with <leader><leader>
nnoremap <leader><leader> <c-^>

" easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Remap VIM 0 to first non-blank character
map 0 ^

" set jj to exit insert mode
imap jj <Esc>

" Map ,g to tag definition
map <leader>g :TagbarToggle<CR>

" reselect when indenting
vnoremap < <gv
vnoremap > >gv

" ctrlp commands
nnoremap <leader>t :CtrlP<cr>
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>f :CtrlPClearCache<cr>

" build bundles
nnoremap <leader>i :BundleInstall!<cr>

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

