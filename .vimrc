syntax on

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
set cursorline!                 " highlight current cursor line

if has("gui_running")
  source $HOME/.guivimrc
endif
"
