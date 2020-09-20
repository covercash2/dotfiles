filetype plugin indent on

" visual style
set number
set relativenumber
syntax on
set background=dark

" don't resize windows when one closes
set noequalalways

" indention
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" set leaders
let mapleader = "\<space>"
let maplocalleader = "\\"

inoremap <silent><expr> <c-space> coc#refresh()

" coc settings
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
set shortmess+=c

" coc shortcuts
nnoremap <silent><nowait> <leader>a :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <leader>c :<C-u>CocList commands<cr>

" mappings
" return to normal mode from terminal mode
tnoremap <Esc> <C-\><C-n>

" org mode
let g:org_todo_keywords = ['TODO', 'WAITING', '|', 'DONE']

"""" convenience commands
" edit the init file in a new buffer
command! EditRc new ~/.local/share/chezmoi/dot_config/nvim/init.vim
" reload init
command! ReloadRc source ~/.config/nvim/init.vim

" return to normal mode on focus lost
function! ReturnToNormalMode()
	if v:insertmode
		feedkeys("\<C-\>\<C-n>")
	endif
endfunction

autocmd FocusLost * call ReturnToNormalMode()

" configure vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_term_mode = "split"

let g:go_fmt_command = "goimports"

let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

" go convenience commands
au FileType go nmap <leader>rs <Plug>(go-run-split)

" update field highlight every .5 seconds
set updatetime=500

" configure vim-plug
call plug#begin()

Plug 'rust-lang-nursery/rustfmt'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go'

Plug 'ctrlpvim/ctrlp.vim'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'Shougo/neco-vim'

Plug 'nsf/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }

Plug 'jiangmiao/auto-pairs'

Plug 'sukima/xmledit', { 'do': 'make' }

Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/utl.vim'

Plug 'rafi/awesome-vim-colorschemes'
Plug 'felixhummel/setcolors.vim'

Plug 'airblade/vim-gitgutter'

Plug 'zchee/libclang-python3'

Plug 'elmcast/elm-vim'
Plug 'dense-analysis/ale'

call plug#end()

" set color theme
colorscheme gruvbox
