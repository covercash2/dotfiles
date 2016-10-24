filetype plugin indent on

" visual style
set number
set relativenumber
syntax on
set background=dark

" indention
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

" set leaders
let maplocalleader = "\\""

" org mode
let g:org_todo_keywords = ['TODO', 'WAITING', '|', 'DONE']

"""" convenience commands
" edit the init file in a new buffer
command! EditRc new ~/.config/nvim/init.vim
" reload init
command! ReloadRc source ~/.config/nvim/init.vim

" open org mode reference
command! OrgHelp vnew ~/notes/vim-orgmode.org

" return to normal mode on focus lost
function! ReturnToNormalMode()
	if v:insertmode
		feedkeys("\<C-\>\<C-n>")
	endif
endfunction

autocmd FocusLost * call ReturnToNormalMode()

autocmd VimEnter * call deoplete#initialize()

" org mode config
let g:org_heading_shade_leading_stars = 1

" deoplete config
let g:deoplete#enable_at_startup = 1
" deoplete-go
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#use_cache = 1
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

" configure vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" configure vim-plug
call plug#begin()

Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neco-vim'
Plug 'zchee/deoplete-go', { 'do': 'make' }

Plug 'nsf/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }

Plug 'jiangmiao/auto-pairs'

Plug 'sukima/xmledit', { 'do': 'make' }

Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-repeat'
Plug 'vim-scripts/utl.vim'

Plug 'flazz/vim-colorschemes'
Plug 'felixhummel/setcolors.vim'

call plug#end()

" set color theme
colorscheme gruvbox
