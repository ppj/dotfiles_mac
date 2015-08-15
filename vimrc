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
Plugin 'tpope/vim-fugitive.git'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-haml'
Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'godlygeek/tabular'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'plasticboy/vim-markdown'
Plugin 'Yggdroot/indentLine'
Plugin 'moll/vim-bbye'            " Close buffer without closing the window using :Bdelete
Plugin 'terryma/vim-expand-region'
Plugin 'mileszs/ack.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'dkprice/vim-easygrep'     " Easy and customizable search and replace in multiple files
Plugin 'christoomey/vim-tmux-navigator' " Navigate Vim and Tmux panes/splits with the same key bindings
Plugin 'benmills/vimux'       " Interact with tmux from vim
Plugin 'skalnik/vim-vroom'    " Ruby test runner that works well with tmux (may render vim-rspec useless)
Plugin 'unblevable/quick-scope'   " Move cursor to any word quickly
" SnipMate Plugin
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'terryma/vim-multiple-cursors'
" All of your Plugins must be added before the following line
call vundle#end()            " required
" ==========================================================================================================

filetype plugin indent on       " required
syntax enable
runtime macros/matchit.vim      " extend % matching to if/elsif/else/end and more
autocmd VimResized * :wincmd =  " Auto-resize splits if window is resized

set hidden                      " manage multiple buffers effectively
set mouse=a                     " allow mouse to set cursor position
set ruler
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

"" Whitespace
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set list                        " highlight whitespace etc.
set listchars=tab:▸\ ,trail:•,extends:❯,nbsp:_,precedes:❮,eol:¬ " Invisible characters

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

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
let mapleader=" "
noremap <leader>l :bn<CR>
noremap <leader>h :bp<CR>
noremap <leader>d :Bd<CR>
noremap <leader>df :Bd!<CR>
noremap <leader>w :w<CR>
noremap <leader>q :q<CR>

" common tasks
noremap <leader>ee :source ~/.vimrc<CR>   " reload vimrc

" Change window-splits easily
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" CtrlP mappings
noremap <leader>oo :CtrlP<CR>         " open file in the project root
noremap <leader>oh :CtrlP %:p:h<CR>   " open (another file) Here, i.e. in the current file's folder
noremap <leader>ob :CtrlPBuffer<CR>   " open (existing) Buffer
noremap <leader>ou :CtrlPMRU<CR>      " open Most-recently-used file
noremap <leader>om :CtrlPMixed<CR>    " MRU/Buffer/Normal modes mixed
noremap <leader>of :Explore<CR>       " open explorer in current File's folder (using vim's native explorer - netrw)

" clipboard copy/paste
vnoremap <leader>x "+x                        " cut in visual mode
vnoremap <leader>c "+y                        " copy in visual mode
noremap <leader>v "+p                         " paste in command mode
inoremap <C-v> <esc>"+p<CR>i                  " paste in insert mode
noremap  <C-a> :%y+"<CR>                      " copy all in normal mode
inoremap <C-a> <esc>:%y+"<CR>i                " copy all in insert mode
nmap <C-S-p> :let @* = expand('%:p')<CR>      " copy full file path

" vim-vroom settings/mappings
let g:vroom_map_keys=0
let g:vroom_use_vimux=1
let g:vroom_cucumber_path='cucumber'  " default: './script/cucumber'
map <leader>tf :VroomRunTestFile<CR>
map <leader>tt :VroomRunNearestTest<CR>
map <leader>tl :VroomRunLastTest<CR>

" airline (status bar) settings
let g:airline#extensions#tabline#enabled=1          " Show buffers as tabs
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_section_z=''

" Git-Gutter settings
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

" Show NERDTREE automatically on opening vim
let NERDTreeShowHidden=1
map <leader>nn :NERDTreeFind<CR><C-W>p    " find current file in NERDTree
map <leader>nc :NERDTreeClose<CR>
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

" Search mappings/settings
let g:ack_default_options =
  \ " -s -H --nocolor --nogroup --column --smart-case --follow --ignore-dir .bundle --ignore-dir tmp --ignore-dir log"
vnoremap <C-S-f> y:Ack! '<C-r>0'
vnoremap // y/<C-R>"<CR>  " search current buffer for selection
