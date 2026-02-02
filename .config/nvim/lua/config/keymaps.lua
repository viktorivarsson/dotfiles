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

vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle [I]nlay [H]int" })

-- Terminal mode window navigation
map("t", "<C-h>", "<C-\\><C-n><C-w>h", silent_options)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", silent_options)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", silent_options)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", silent_options)

-- Accept AI inline suggestion with <C-j>, otherwise accept Blink dropdown with <C-y>
vim.keymap.set("i", "<C-j>", function()
  -- Try Copilot suggestion first (zbirenbaum/copilot.lua)
  local ok_copilot, copilot_suggestion = pcall(require, "copilot.suggestion")
  if ok_copilot and copilot_suggestion and copilot_suggestion.is_visible and copilot_suggestion.is_visible() then
    copilot_suggestion.accept()
    return
  end

  -- Fallback: send Blink dropdown accept (<C-y>)
  local keys = vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { silent = true })
