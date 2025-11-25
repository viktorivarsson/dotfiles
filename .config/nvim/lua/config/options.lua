-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

opt.clipboard = ""

-- Don't auto open ocmment on new lines
autocmd("BufEnter", {
  pattern = "",
  command = "set fo-=c fo-=r fo-=o",
})

-- Disable animations in snacks
vim.g.snacks_animate = false

-- Struggle with tmux escape time
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

vim.opt.wrap = true
vim.opt.swapfile = false

-- vim.opt.signcolumn = "yes"

vim.lsp.inlay_hint.enable(false)
