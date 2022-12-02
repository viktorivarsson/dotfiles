vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.hidden = true
vim.opt.errorbells = false

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
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
vim.g.neoformat_enabled_typescript =
	{ "tsfmt", "prettierd", "prettier", "prettiereslint", "tslint", "eslint_d", "denofmt" }
vim.g.neoformat_enabled_typescriptreact =
	{ "tsfmt", "prettierd", "prettier", "prettiereslint", "tslint", "eslint_d", "denofmt" }

vim.g.gitblame_enabled = 0
vim.g.gitblame_message_template = "<author> • <date> • <summary>"
vim.g.gitblame_date_format = "%r (%Y-%m-%d)"

vim.g.netrw_winsize = 25
