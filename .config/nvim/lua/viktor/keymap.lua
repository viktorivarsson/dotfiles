local map = vim.api.nvim_set_keymap

-- Map leader
map("n", "<space>", "", {})
vim.g.mapleader = " " -- 'vim.g' sets global variables

local options = { noremap = true }
local silent_options = { noremap = true, silent = true }

-- ex
map("n", "<leader>pv", ":Ex<cr>", silent_options)

-- Move lines up / down
map("v", "J", ":m '>+1<cr>gv=gv", options)
map("v", "K", ":m '<-2<cr>gv=gv", options)

map("n", "<c-d>", "<c-d>zz", silent_options)
map("n", "<c-u>", "<c-u>zz", silent_options)

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
map("n", "<leader>2", ":lua reload_nvim_conf()<cr>", options)
