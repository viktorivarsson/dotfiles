local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Auto format on save
augroup("AutoFormat", { clear = false })
autocmd("BufWritePre", {
	group = "AutoFormat",
	pattern = "*",
	command = "undojoin | Neoformat",
})

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = "YankHighlight",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = "50" })
	end,
})

-- Don't auto open ocmment on new lines
autocmd("BufEnter", {
	pattern = "",
	command = "set fo-=c fo-=r fo-=o",
})
