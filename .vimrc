" Keep Plug commands between plug#begin() and plug#end().
call plug#begin()
Plug 'sheerun/vim-polyglot'
" Plug 'jparise/vim-graphql'        " GraphQL syntax
" Plug 'elixir-lang/vim-elixir'     " Elixir syntax
" Plug 'styled-components/vim-styled-components'
Plug 'haishanh/night-owl.vim'
Plug 'itchyny/lightline.vim'
Plug 'TaDaa/vimade'
Plug 'tpope/vim-fugitive'         " :Gblame
Plug 'airblade/vim-gitgutter'     " Show git diff of lines edited
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'junegunn/fzf.vim'           " Set up fzf and fzf.vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim' , { 'branch' : 'release' }
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-dispatch'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
call plug#end()


" ================ 1. CONFIG ======================
syntax on
filetype plugin indent on       " https://vi.stackexchange.com/questions/10124/what-is-the-difference-between-filetype-plugin-indent-on-and-filetype-indent
colorscheme night-owl           " Editor theme
set guifont=Dank\ Mono:h14      " Font

" File extension map to filetype overrides
au BufRead,BufNewFile *.jsx set filetype=javascript.jsx
au BufRead,BufNewFile *.tsx set filetype=typescript.tsx

set encoding=utf-8              " Presentation encoding
set termencoding=utf-8          " Keyboard encoding
set clipboard=unnamed           " Allow copy paste from system clipboard

" File swap / backup settings
set nobackup                    " No backup files
set nowritebackup               " No backups while editing
set noswapfile                  " No swap files

set history=1000                " Store lots of :cmdline history
set visualbell                  " No sounds
" set colorcolumn=80              " Column width border
set laststatus=2                " Always show status line
set wrap!                       " Turn off wrapping of text
set nu rnu                      " Line numbers
set backspace=indent,eol,start  " Backspace settings

" Indentation settings
set smartindent                 " No idea how this works
set autoindent                  " Keep indentation for next line
set shiftwidth=2                " Indendation step for << and >>
set tabstop=2                   " Width of <TAB>
set expandtab                   " Convert tabs to spaces on <TAB>

" Search settings
set ignorecase                  " Case insensitivity search
set smartcase                   " Skip ignore case when search contains capitals
set incsearch                   " Incremental search - results as you type

set hidden                      " Hide buffer with unsaved changes without warning
set updatetime=300              " Default updatetime leads to delays (CoC)

let g:coc_global_extensions = [
  \ 'coc-bookmark',
  \ 'coc-css',
  \ 'coc-cssmodules',
  \ 'coc-eslint',
  \ 'coc-json',
  \ 'coc-phpls',
  \ 'coc-prettier',
  \ 'coc-rls',
  \ 'coc-graphql',
  \ 'coc-snippets',
  \ 'coc-tsserver'
  \ ]

let g:fzf_layout = { 'down': '40%' }
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'

" NERDTree
let NERDTreeAutoDeleteBuffer=1  " Close a deleted files buffer
let NERDTreeDirArrows=1         " Tree directory arrows
let NERDTreeMinimalUI=1         " Hide bookmarks label
let NERDTreeQuitOnOpen=1        " Close NERDTree after opening file
let NERDTreeShowHidden=1        " Show hidden files
let g:NERDTreeWinSize=60        " Width of sidebar


" ================ 2. BEHAVIOR ======================
set splitbelow
set splitright

" Delete empty space from the end of lines on every save
autocmd BufWritePre * :%s/\s\+$//e

" FZF default search command
let $FZF_DEFAULT_COMMAND="rg --files --follow --hidden --glob '!{node_modules/*,.git/*,dist/*}'"

" RipGrep search override to add glob over fzf definition
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --glob ''!yarn.lock'' -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Set RipGrep root to working directory
if executable('rg')
  let g:rg_derive_root='true'
endif

" CoC - signcolumn to avoid layout change when checking lints and stuff
if has("patch-8.1.1564")
  set signcolumn=number " Recently vim can merge signcolumn and number column into one
else
  set signcolumn=yes
endif


" ================ 3. KEYMAPS ======================

nnoremap <space> <nop>
let mapleader=" "

nnoremap <leader>b :buffers<cr>:b<space>

" FZF
nnoremap <c-p> :Files<cr>
nnoremap <leader>t :BTags<cr>
nnoremap <leader>T :Tags<cr>
nnoremap <leader>l :Lines<cr>
nnoremap <silent> <leader>x :Commits<cr>
nnoremap <silent> <leader>rg :Rg<cr>

" NERDTree
nnoremap <leader>ft :NERDTreeToggle<Enter>
nnoremap <leader>ff :NERDTreeFind<Enter>

" CoC Suggestions
inoremap <silent><expr> <c-Space> coc#refresh()
inoremap <expr> <c-j> pumvisible() ? "\<c-n>" : "\<c-j>"
inoremap <expr> <c-k> pumvisible() ? "\<c-p>" : "\<c-k>"
inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<c-g>u\<cr>"

" CoC Actions
nnoremap <silent>K :call <sid>show_documentation()<cr>
nmap <leader>sd :CocDiagnostics<cr>
nmap <leader>do <plug>(coc-codeaction)
nmap <leader>qf <plug>(coc-fix-current)
nmap <leader>rn <plug>(coc-rename)

" CoC Go to
nmap <silent>gd <plug>(coc-definition)
nmap <silent>gy <plug>(coc-type-definition)
nmap <silent>gi <plug>(coc-implementation)
nmap <silent>gr <plug>(coc-references)

" CoC Snippets
imap <c-l> <plug>(coc-snippets-expand)
vmap <c-j> <plug>(coc-snippets-select)
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

" CoC Bookmarks
nmap <Leader>bb <Plug>(coc-bookmark-toggle)
nmap <Leader>bj <Plug>(coc-bookmark-next)
nmap <Leader>bk <Plug>(coc-bookmark-prev)

" Save and exit shortcuts
nnoremap <silent><leader>w :w!<cr>
nnoremap <silent><leader>q :q!<cr>
nnoremap <silent><leader>x :x<cr>

" File open / close shortcuts
nnoremap <silent><leader>bd :bd<cr>
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR>
nnoremap <silent><leader>2 :e ~/.vimrc<cr>

" Window splits
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" Move lines in normal mode
nnoremap <c-j> :m .+1<cr>==
nnoremap <c-k> :m .-2<cr>==

" Move lines in visual mode
vnoremap <c-j> :m '>+1<cr>gv=gv
vnoremap <c-k> :m '<-2<cr>gv=gv


" ================ 4. UTILS ======================

" Used by CoC
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction


" ================ 5. OLD SHIET ======================

" Prettier binding to format file
" command! -nargs=0 Prettier :CocCommand prettier.formatFile

" highlight ColorColumn ctermbg=0 guibg=lightgrey
"
" " Add CoC Prettier if prettier is installed
" if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
"   let g:coc_global_extensions += ['coc-prettier']
" endif

" " Add CoC ESLint if ESLint is installed
" if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
"   let g:coc_global_extensions += ['coc-eslint']
" endif
