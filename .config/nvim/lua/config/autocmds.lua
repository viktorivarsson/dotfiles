-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- https://github.com/yetone/avante.nvim/issues/1759#issuecomment-2770887161
local chdir = vim.api.nvim_create_augroup("chdir", {})
vim.api.nvim_create_autocmd("BufEnter", {
  group = chdir,
  nested = true,
  callback = function()
    vim.go.autochdir = false
    -- vim.go.autochdir = not vim.bo.filetype:match("^Avante")
  end,
})
