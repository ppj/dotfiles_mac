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
Plugin 'VundleVim/Vundle.vim'
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
Plugin 'w0rp/ale'                 " async syntax checking
Plugin 'henrik/vim-indexed-search'  " search count display & more search customisations
Plugin 'liuchengxu/vim-which-key'

" Look & Feel Plugins
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Yggdroot/indentLine'

" Browsing & File-search
Plugin 'scrooloose/nerdtree'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mileszs/ack.vim'          " Frontrunner for Ag because of the config
Plugin 'diepm/vim-rest-console'

" Motion
Plugin 'Lokaltog/vim-easymotion'

" Git
Plugin 'tpope/vim-fugitive.git'
Plugin 'tpope/vim-rhubarb.git'
Plugin 'airblade/vim-gitgutter'
Plugin 'Xuyuanp/nerdtree-git-plugin'

" Ruby (& Rails)
Plugin 'tpope/vim-rails'
Plugin 'vim-scripts/blockle.vim'        " toggle ruby block styles between {} and do/end
Plugin 'ecomba/vim-ruby-refactoring'    " use-cases - https://goo.gl/fYyNnD
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-cucumber'             " cucumber syntax highlighting
Plugin 'slim-template/vim-slim'         " For slim templates
Plugin 'tpope/vim-haml'                 " For haml templates

" Tmux & co
Plugin 'christoomey/vim-tmux-navigator' " Navigate Vim and Tmux panes/splits with the same key bindings
Plugin 'benmills/vimux'       " Interact with tmux from vim
Plugin 'skalnik/vim-vroom'    " Ruby test runner that works well with tmux

" Elixir & co
Plugin 'elixir-lang/vim-elixir'
Plugin 'slashmili/alchemist.vim'
Plugin 'mhinz/vim-mix-format'

" JavaScript & co
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'mattn/emmet-vim'
Plugin 'prettier/vim-prettier'
Plugin 'leafgarland/typescript-vim'

" Markdown & co
Plugin 'plasticboy/vim-markdown'

" OpenAPI & co
Plugin 'hsanson/vim-openapi'

" GitHub Copilot
Plugin 'github/copilot.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
" ==========================================================================================================

filetype plugin indent on       " required
syntax on
runtime macros/matchit.vim      " extend % matching to if/elsif/else/end and more
autocmd VimResized * :wincmd =  " Auto-resize splits if window is resized

let mapleader=" "
set hidden                      " manage multiple buffers effectively
set mouse+=a                    " allow mouse to set cursor position
" Resize splits in vim in tmux with mouse (source: https://superuser.com/a/550482)
if &term =~ '^screen'
  " tmux knows the extended mouse mode
  set ttymouse=xterm2
endif
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
set cursorcolumn                " highlight current column
set number                      " show line numbers
" augroup numbertoggle
"   autocmd!
"   autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
"   autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
" augroup END
nnoremap <leader>rr :set rnu!<CR> " toggle relative line numbers

" highlight column # 121 (line too long)
set colorcolumn=121

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
" set regexpengine=1    "  vim 7.3 + regex parser isn't great. Vim slows down with big ruby files
set regexpengine=0      "  auto-select (1 causing problems for TypeScript syntax highlighting) Ref: https://bit.ly/2V1w5y7
set hlsearch            "  highlight matches
set incsearch           "  incremental searching
set ignorecase          "  searches are case insensitive...
set smartcase           "  ... unless they contain at least one capital letter
vmap * y/<C-R>"<CR> "  search current buffer for selection
vmap # y?<C-R>"<CR> "  search current buffer for selection
" search forward in selection
vmap / <ESC>/\%V
" search backward in selection
vmap ? <ESC>?\%V
nnoremap <CR> :noh<CR><CR> " turn off search highlighting on Enter

" vim-indexed-search settings
let g:indexed_search_dont_move = 1
let g:indexed_search_colors = 0
let g:indexed_search_shortmess = 1
let g:indexed_search_numbered_only = 1
let g:indexed_search_n_always_searches_forward = 1

" vim-whick-key settings
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
set timeoutlen=500 " defaults to 1000ms

" vim-rails
nnoremap <leader>aa :A<CR>   "  alternate file
nnoremap <leader>av :AV<CR>  "  alternate file in vertical split

" fugitive
nnoremap <leader>gg :Git<CR> " git status
nnoremap <leader>gd :Gdiff<CR> " git diff current file
nnoremap <leader>gb :Git blame<CR> " git blame current file
nnoremap <leader>go :GBrowse<CR> " git browse current file
nnoremap <leader>gl :Gpull<CR> " git pull
nmap <leader>gc :Git checkout<space>
nmap <leader>gp :Gpush<space>

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
noremap <leader>x :Bd<CR>
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

" CtrlP mappings/settings
noremap <leader>ff :CtrlP<CR>         " open file in the project root
noremap <leader>fh :CtrlP %:p:h<CR>   " open (another file) Here, i.e. in the current file's folder
noremap <leader>fb :CtrlPBuffer<CR>   " open (existing) Buffer
noremap <leader>fr :CtrlPMRU<CR>      " open Most-recently-used file
noremap <leader>fm :CtrlPMixed<CR>    " MRU/Buffer/Normal modes mixed
" Make CtrlP use ag for listing the files. Way faster and no useless files.
" Without --hidden, it never finds .travis.yml since it starts with a dot
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
let g:ctrlp_use_caching = 0
let g:ctrlp_mruf_relative = 1

" use system clipboard
set clipboard=unnamed

" copy file path to clipboard
nnoremap <leader>pp :let @+ = expand('%:.')<CR>  " copy relative file path
nnoremap <leader>pf :let @+ = expand('%:p')<CR>  " copy full file path

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
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)

" NERDTREE mappings & settings
let NERDTreeShowHidden=1
let NERDTreeMapJumpNextSibling="L"
let NERDTreeMapJumpPreviousSibling="H"
noremap <leader>nn :NERDTreeToggle<CR>  " toggle NERDTree window
noremap <leader>nf :NERDTreeFind<CR>    " find current file in NERDTree

" ale mappings & settings
let g:ale_linters = {'javascript': ['eslint'], 'ruby': ['standardrb']}
let g:ale_fixers = {'ruby': ['standardrb']}
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1

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

" vim-jsx settings
let g:jsx_ext_required = 0

" ruby autoformatting settings
let g:ruby_indent_assignment_style = 'variable'

" vim-mix-format settings
let g:mix_format_options = '--check-equivalent'
noremap <leader>mm :MixFormat<CR>
noremap <leader>md :MixFormatDiff<CR>

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

" move line(s) up/down with Alt+k/j (http://vim.wikia.com/wiki/Moving_lines_up_or_down)
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

" autocomplete with tab when typing words only (http://bit.ly/29xSbgb)
function! Tab_Or_Complete()
  if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
    return "\<C-P>"
  else
    return "\<Tab>"
  endif
endfunction
inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>

" spell-check on for certain filetypes
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_au
autocmd FileType gitcommit setlocal spell spelllang=en_us
