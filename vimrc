set nocompatible              " choose no compatibility with legacy vi
filetype plugin indent on     " required
syntax enable
set hidden                    " manage multiple buffers effectively
set mouse=a                   " allow mouse to set cursor position
runtime macros/matchit.vim    " extend % matching to if/elsif/else/end and more
set wildmenu                  " file/command completion shows options...
set wildmode=list:longest     " ...only up to the point of ambiguity
set dir=/tmp                  " store swp files in this folder (it needs to exist)
set splitbelow                " horizontal split with new window below the current window
set splitright                " vertical split with new window to the right side of current window

" clear all previous bindings
" autocmd! "this is causing syntax highlighting issues for some reason

" move cursor up/down by screen lines instead of real lines
nmap k gk
nmap j gj

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" "call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" MISSING

" Keep Plugin commands between vundle#begin/end.
Plugin 'tpope/vim-fugitive.git'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'thoughtbot/vim-rspec'
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
" SnipMate Plugin
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'terryma/vim-multiple-cursors'
" All of your Plugins must be added before the following line
call vundle#end()            " required
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

" set colorscheme
let g:mopkai_is_not_set_normal_ctermbg = 1
colorscheme mopkai

set encoding=utf-8        " nobomb disables the Ex mode (coz' i don't know what it's really used for)
set showcmd               " display incomplete commands
set laststatus=2
set t_Co=256
set cursorline                          " highlight current line
hi CursorLine cterm=bold ctermbg=235
set number                              " show line numbers

"" Whitespace
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set list                        " highlight whitespace etc.
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

" Delete trailing white space(s) before saving buffer
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

autocmd BufWritePost ~/.vimrc so ~/.vimrc

nnoremap <Space> <Nop>
let mapleader=" "
noremap <leader>l :bn<CR>
noremap <leader>h :bp<CR>
noremap <leader>d :Bd<CR>
noremap <leader>df :Bd!<CR>
noremap <leader>w :w<CR>
noremap <leader>q :q<CR>
noremap <leader>o :CtrlP<CR>
" <leader>-x to cut in + buffer from visual mode
vnoremap <leader>x "+x
" <leader>-c to copy in + buffer from visual mode
vnoremap <leader>c "+y
" <leader>-v to paste from the + register in cmd mode
noremap <leader>v "+p
" Ctrl-v to paste from the + register while editing
inoremap <C-v> <esc>"+p<CR>i
" Ctrl-a to select all & copy in + buffer
noremap  <C-a> :%y+"<CR>
inoremap <C-a> <esc>:%y+"<CR>i
" Select text with shift+arrows in insert mode
set guioptions+=a keymodel=startsel,stopsel

" RSpec.vim mappings
let g:rspec_command = "!clear && zeus rspec {spec}"
map <leader>t :call RunCurrentSpecFile()<CR>
map <leader>n :call RunNearestSpec()<CR>
map <leader>p :call RunLastSpec()<CR>
map <leader>a :call RunAllSpecs()<CR>

" mappings for running cukes
map <leader>cf :w<cr>:!zeus cucumber %<cr>                          " current cucumber file
map <leader>cc :w<cr>:exe "!zeus cucumber %" . ":" . line(".")<cr>  " current cucumber scenario


let g:airline#extensions#tabline#enabled=1          " Show buffers as tabs
" let g:airline#extensions#tabline#fnamemod = ':t'  " Show just the filename
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_section_z=''

" Git-Gutter settings
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0

" Show NERDTREE automatically on opening vim
" autocmd vimenter * NERDTree
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
