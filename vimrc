" ==========================================================================================================
" Plugins (Vundle Stuff)
" ==========================================================================================================
set nocompatible              " choose no compatibility with legacy vi (required by Vundle)
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" first, let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Keep Plugin commands between vundle#begin/end.

" Functionality
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-repeat'         " repeat last Plugin command with '.'
Plugin 'godlygeek/tabular'        " code alignment (this needs to come before vim-markdown)
Plugin 'moll/vim-bbye'            " Close buffer without closing the window using :Bdelete
Plugin 'tpope/vim-endwise'        " 'end' most 'do's wisely
Plugin 'terryma/vim-multiple-cursors'
Plugin 'jiangmiao/auto-pairs'     " auto complete matching pair

" Look & Feel Plugins
Plugin 'tpope/vim-haml'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'plasticboy/vim-markdown'
Plugin 'Yggdroot/indentLine'

" Browsing & File-search
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'mileszs/ack.vim'          " Frontrunner for Ag because of the config

" Motion
Plugin 'Lokaltog/vim-easymotion'

" Git
Plugin 'tpope/vim-fugitive.git'
Plugin 'airblade/vim-gitgutter'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" Ruby (& Rails)
Plugin 'tpope/vim-rails'
Plugin 'vim-scripts/blockle.vim'        " toggle ruby block styles between {} and do/end
Plugin 'ecomba/vim-ruby-refactoring'    " use-cases - https://goo.gl/fYyNnD
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-cucumber'             " cucumber syntax highlighting

" Tmux & co.
Plugin 'christoomey/vim-tmux-navigator' " Navigate Vim and Tmux panes/splits with the same key bindings
Plugin 'benmills/vimux'       " Interact with tmux from vim
Plugin 'skalnik/vim-vroom'    " Ruby test runner that works well with tmux

" Elixir (& co)
Plugin 'elixir-lang/vim-elixir'
Plugin 'slashmili/alchemist.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
" ==========================================================================================================

filetype plugin indent on       " required
syntax enable
runtime macros/matchit.vim      " extend % matching to if/elsif/else/end and more
autocmd VimResized * :wincmd =  " Auto-resize splits if window is resized

set hidden                      " manage multiple buffers effectively
set mouse=a                     " allow mouse to set cursor position
set wildmenu                    " file/command completion shows options...
set wildmode=list:longest       " ...only up to the point of ambiguity
set dir=/tmp                    " store swp files in this folder (it needs to exist)
set splitbelow                  " horizontal split with new window below the current window
set splitright                  " vertical split with new window to the right side of current window
set encoding=utf-8
set showcmd                     " display incomplete commands
set laststatus=2
set t_Co=256
set cursorline                  " highlight current line
set number                      " show line numbers
set relativenumber              " show relative line numbers

" highligh column # 121 (line too long)
set colorcolumn=121

let mapleader=" "

" Whitespace
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set list                        " highlight whitespace etc.
set listchars=tab:▸\ ,trail:•,extends:❯,nbsp:_,precedes:❮,eol:¬ " Invisible characters

" Grep
if executable('ag')
  " Use ag for Ack.vim
  let g:ackprg = 'ag --nogroup --column --smart-case --nocolor --follow --vimgrep'

  " Use ag over grep
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ --vimgrep
  set grepformat=%f:%l:%C:%m
endif

" Searching
set regexpengine=1      "  vim 7.3 + regex parser isn't great. Vim slows down with big ruby files
set hlsearch            "  highlight matches
set incsearch           "  incremental searching
set ignorecase          "  searches are case insensitive...
set smartcase           "  ... unless they contain at least one capital letter
vnoremap * y/<C-R>"<CR> "  search current buffer for selection
vnoremap # y?<C-R>"<CR> "  search current buffer for selection
" search forward in selection
vnoremap / <ESC>/\%V
" search backward in selection
vnoremap ? <ESC>?\%V

" always search forward by `n` and backward by `N`
nnoremap <expr> n  'Nn'[v:searchforward]
nnoremap <expr> N  'nN'[v:searchforward]

" vim-rails
nnoremap <leader>aa :A<CR>   "  alternate file
nnoremap <leader>av :AV<CR>  "  alternate file in vertical split

" fugitive
nnoremap <leader>gg :Gsta<CR>  " git status
nnoremap <leader>gd :Gdiff<CR><C-W>p  " git diff current file & switch to working copy
nnoremap <leader>gb :Gblame<CR>  " git blame current file

" Select text with shift+arrows in insert mode
set guioptions+=a keymodel=startsel,stopsel

" move cursor up/down by screen lines ONLY WHEN used without a count
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

let g:indentLine_color_term = 237

let g:mopkai_is_not_set_normal_ctermbg = 1
colorscheme mopkai

" Delete trailing white space(s) before saving buffer
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

nnoremap Q <nop>          " disable ex-mode

" buffer actions mappings
nnoremap <Space> <Nop>
noremap <leader>l :bn<CR>
noremap <leader>h :bp<CR>
noremap <leader>d :Bd<CR>
noremap <leader>b :ls<cr>:b<space>
noremap <leader>w :w<CR>
noremap <leader>q :q<CR>
noremap <leader>e :e<CR>    " reload file

" avoid some windows when cycling thru buffers by hiding them
augroup HideBuffer
  autocmd!
  " quickfix window (https://redd.it/2o9d3o)
  autocmd FileType qf setlocal nobuflisted

  " the Gstatus buffer (http://bit.ly/29xSbgb)
  autocmd BufReadPost *.git/index  set nobuflisted

  " the Gstatus buffer (http://bit.ly/29xSbgb)
  autocmd BufReadPost *.g/COMMIT_EDITMSG  set nobuflisted
augroup END

" Change window-splits easily
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-b> <C-w>p

" who needs folding?!
set nofoldenable

" CtrlP mappings/settings
noremap <leader>oo :CtrlP<CR>         " open file in the project root
noremap <leader>oh :CtrlP %:p:h<CR>   " open (another file) Here, i.e. in the current file's folder
noremap <leader>ob :CtrlPBuffer<CR>   " open (existing) Buffer
noremap <leader>ou :CtrlPMRU<CR>      " open Most-recently-used file
noremap <leader>om :CtrlPMixed<CR>    " MRU/Buffer/Normal modes mixed
noremap <leader>of :Explore<CR>       " open explorer in current File's folder (using vim's native explorer - netrw)
" Make CtrlP use ag for listing the files. Way faster and no useless files.
" Without --hidden, it never finds .travis.yml since it starts with a dot
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
let g:ctrlp_use_caching = 0

" clipboard copy/paste
vnoremap <leader>x "+x                        " cut in visual mode
vnoremap <leader>c "+y                        " copy in visual mode
noremap  <C-a> :%y+"<CR>                      " copy all in normal mode
noremap <leader>v "+p                         " paste in command mode
inoremap <C-v> <esc>"+pi                      " paste in insert mode

" copy file path to clipboard
nnoremap <leader>ff :let @* = expand('%:p')<CR>  " copy full file path

" vim-vroom mappings & settings
let g:vroom_map_keys=0
let g:vroom_use_vimux=1
let g:vroom_cucumber_path='cucumber'  " default: './script/cucumber'
let g:vroom_ignore_color_flag=1
noremap <leader>tf :VroomRunTestFile<CR>
noremap <leader>tt :VroomRunNearestTest<CR>
noremap <leader>tl :VroomRunLastTest<CR>

" airline (status bar) settings
let g:airline#extensions#tabline#enabled=1          " Show buffers as tabs
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''

" Git-Gutter mappings & settings
let g:gitgutter_map_keys = 0
nmap ]c <Plug>GitGutterNextHunk
nmap [c <Plug>GitGutterPrevHunk

" NERDTREE mappings & settings
let NERDTreeShowHidden=1
noremap <leader>nn :NERDTreeFind<CR>    " find current file in NERDTree
noremap <leader>nc :NERDTreeClose<CR>
" Close vim if only window open is NERDTREE
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" vim-markdown settings
let vim_markdown_folding_disabled=1
let vim_markdown_conceal=0

" Twiddle Case: '~' to cycle between UPPER, lower & Title cases on visual selection
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" Search in files mappings/settings
" let g:ack_default_options = " -s -H --nocolor --nogroup --column --smart-case --follow --ignore-dir .bundle --ignore-dir tmp --ignore-dir log"
vmap <C-f> y:Ack! '<C-r>0'<Esc>
nmap <C-f> yiw:Ack! <C-r>0<Esc>

" Some commonly used Tabular mappings
if exists(":Tabularize")
  noremap <leader>a:  :Tabularize /:\zs<CR>       " Align everything after a ':'
  noremap <leader>a=  :Tabularize /=<CR>          " Align everything around '='
  noremap <leader>a|  :Tabularize /|<CR>          " Align everything around '|'
endif

" common tasks
noremap <leader>ee :source ~/.vimrc<CR>   " reload vimrc
" command history mode (default)
nnoremap : q:i
" simple command prompt
nnoremap <leader>: :

" easy edit
" move line(s) up/down with Alt+k/j (http://vim.wikia.com/wiki/Moving_lines_up_or_down)
vnoremap ∆ :m '>+1<CR>gv
vnoremap ˚ :m '<-2<CR>gv

" autocomplete with tab when typing words only (http://bit.ly/29xSbgb)
function! Tab_Or_Complete()
  if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
    return "\<C-P>"
  else
    return "\<Tab>"
  endif
endfunction
inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>
