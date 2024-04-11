-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.api.nvim_set_keymap
local options = { noremap = true }
local silent_options = { noremap = true, silent = true }

-- copy relative file path to clipboard
map("n", "<leader>fp", ":let @+ = expand('%')<cr>", { desc = "Copy relative [F]ile [P]ath to clipboard" })

-- Move lines up / down
map("v", "J", ":m '>+1<cr>gv=gv", options)
map("v", "K", ":m '<-2<cr>gv=gv", options)
map("v", "<s-down>", ":m '>+1<cr>gv=gv", options)
map("v", "<s-up>", ":m '<-2<cr>gv=gv", options)

-- Center after navigation commands
map("n", "<c-d>", "<c-d>zz", silent_options)
map("n", "<c-u>", "<c-u>zz", silent_options)
map("n", "n", "nzz", silent_options)
map("n", "N", "Nzz", silent_options)

-- No hl search
map("n", "<leader>nl", ":nohlsearch<cr>", { desc = "No [H]ighlight [L]ast search", silent = true })

-- Yank and paste
map("x", "<leader>p", '"_dP', options)
map("v", "<leader>y", '"*y', options)
