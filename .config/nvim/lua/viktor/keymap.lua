local map = vim.api.nvim_set_keymap

-- Map leader
map("n", "<space>", "", {})
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local options = { noremap = true }
local silent_options = { noremap = true, silent = true }

-- ex
map("n", "<leader>pv", ":Ex<cr>", silent_options)

-- copy relative file path to clipboard
map("n", "<leader>fp", ":let @+ = expand('%')<cr>", silent_options)

-- Move lines up / down
map("v", "J", ":m '>+1<cr>gv=gv", options)
map("v", "K", ":m '<-2<cr>gv=gv", options)

-- Center after navigation commands
map("n", "<c-d>", "<c-d>zz", silent_options)
map("n", "<c-u>", "<c-u>zz", silent_options)
map("n", "n", "nzz", silent_options)
map("n", "N", "Nzz", silent_options)

-- No hl search
map("n", "<leader>nl", ":nohlsearch<cr>", silent_options)

-- Yank and paste
map("x", "<leader>p", '"_dP', options)
map("v", "<leader>y", '"*y', options)

-- Save and exit shortcuts
map("n", "<leader>w", ":w!<cr>", options)
map("n", "<leader>q", ":q!<cr>", options)

-- Buffers
map("n", "<leader>bd", ":bd<cr>", options)
map("n", "<leader>bb", ":buffers<cr>", options)

-- Edit VIM
map("n", "<leader>1", ":e $MYVIMRC<cr>", options)
