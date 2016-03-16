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
Plugin 'terryma/vim-expand-region'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-repeat'         " repeat last Plugin command with '.'
Plugin 'godlygeek/tabular'        " code alignment
Plugin 'moll/vim-bbye'            " Close buffer without closing the window using :Bdelete
Plugin 'tpope/vim-endwise'        " 'end' most 'do's wisely
Plugin 'terryma/vim-multiple-cursors'
Plugin 'jiangmiao/auto-pairs'     " auto complete matching pair

" Look & Feel Plugins
Plugin 'tpope/vim-haml'
Plugin 'bling/vim-airline'
Plugin 'plasticboy/vim-markdown'
Plugin 'Yggdroot/indentLine'

" Browsing & File-search
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'dkprice/vim-easygrep'     " Easy and customizable search and replace in multiple files
" Plugin 'mileszs/ack.vim'
Plugin 'rking/ag.vim'             " replacement for 153% of the uses of Ack

" Motion
Plugin 'Lokaltog/vim-easymotion'
Plugin 'unblevable/quick-scope'   " Move cursor to any word quickly

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

" SnipMate Plugin
Plugin 'garbas/vim-snipmate'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'

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

let mapleader=" "

" Whitespace
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set list                        " highlight whitespace etc.
set listchars=tab:▸\ ,trail:•,extends:❯,nbsp:_,precedes:❮,eol:¬ " Invisible characters

" Searching
set hlsearch            "  highlight matches
set incsearch           "  incremental searching
set ignorecase          "  searches are case insensitive...
set smartcase           "  ... unless they contain at least one capital letter
vnoremap * y/<C-R>"<CR> "  search current buffer for selection
vnoremap # y?<C-R>"<CR> "  search current buffer for selection

" vim-rails
nnoremap <leader>aa :A<CR>   "  alternate file
nnoremap <leader>av :AV<CR>  "  alternate file in vertical split

" Select text with shift+arrows in insert mode
set guioptions+=a keymodel=startsel,stopsel

hi CursorLine cterm=bold ctermbg=235

" move cursor up/down by screen lines instead of real lines
nmap k gk
nmap j gj

let g:indentLine_color_term = 237

fun! SetupVAM()
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'

  " Force your ~/.vim/after directory to be last in &rtp always:
  " let g:vim_addon_manager.rtp_list_hook = 'vam#ForceUsersAfterDirectoriesToBeLast'

  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif

  " This provides the VAMActivate command, you could be passing plugin names, too
  call vam#ActivateAddons([], {})
endfun
call SetupVAM()
ActivateAddons vim-snippets snipmate

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
noremap <leader>df :Bd!<CR>
noremap <leader>w :w<CR>
noremap <leader>q :q<CR>

" Change window-splits easily
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

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
noremap <leader>v "+p                         " paste in command mode
inoremap <C-v> <esc>"+p<CR>i                  " paste in insert mode
noremap  <C-a> :%y+"<CR>                      " copy all in normal mode
inoremap <C-a> <esc>:%y+"<CR>i                " copy all in insert mode
nnoremap <C-S-p> :let @* = expand('%:p')<CR>  " copy full file path

" vim-vroom settings/mappings
let g:vroom_map_keys=0
let g:vroom_use_vimux=1
let g:vroom_cucumber_path='cucumber'  " default: './script/cucumber'
noremap <leader>tf :VroomRunTestFile<CR>
noremap <leader>tt :VroomRunNearestTest<CR>
noremap <leader>tl :VroomRunLastTest<CR>

" airline (status bar) settings
let g:airline#extensions#tabline#enabled=1          " Show buffers as tabs
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''

" Git-Gutter settings
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

" Show NERDTREE automatically on opening vim
let NERDTreeShowHidden=1
noremap <leader>nn :NERDTreeFind<CR>    " find current file in NERDTree
noremap <leader>nc :NERDTreeClose<CR>
" Close vim if only window open is NERDTREE
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" v to expand selection and Shift-v to shrink selection
vmap v <Plug>(expand_region_expand)
vmap <S-v> <Plug>(expand_region_shrink)

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
vmap <C-S-f> y:Ag! '<C-r>0'<Esc>
nmap <C-S-f> yiw:Ag! '<C-r>0'<Esc>

" Some commonly used Tabular mappings
if exists(":Tabularize")
  noremap <leader>a:  :Tabularize /:\zs<CR>       " Align everything after a ':'
  noremap <leader>a=  :Tabularize /=<CR>          " Align everything around '='
  noremap <leader>a|  :Tabularize /|<CR>          " Align everything around '|'
endif

" common tasks
noremap <leader>ee :source ~/.vimrc<CR>   " reload vimrc
nnoremap : q:i

" easy edit
" move line(s) up/down with Alt+k/j (http://vim.wikia.com/wiki/Moving_lines_up_or_down)
nnoremap ∆ :m .+1<CR>           # ∆ is Alt+j (http://stackoverflow.com/a/15399297)
nnoremap ˚ :m .-2<CR>           # ˚ is Alt+k (http://stackoverflow.com/a/15399297)
vnoremap ∆ :m '>+1<CR>gv
vnoremap ˚ :m '<-2<CR>gv
