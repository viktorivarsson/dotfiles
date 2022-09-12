vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.errorbells = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

vim.opt.swapfile = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- Give more space for displaying messages.
vim.opt.cmdheight = 1

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50


vim.g.neoformat_try_node_exe = 1

vim.api.nvim_create_autocmd(
  { "BufWritePre", "TextChanged" ,"InsertLeave" },
  { pattern = "*", command = "Neoformat" }
)
