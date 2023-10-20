return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			-- vim.cmd.colorscheme("catppuccin-macchiato")
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
	{
		"folke/tokyonight.nvim",
		config = function()
			-- vim.cmd.set("background=dark")
			-- vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	{
		"navarasu/onedark.nvim",
		config = function()
			-- require("onedark").setup({
			-- 	style = "darker",
			-- })
			-- require("onedark").load()
		end,
	},
	{
		"yazeed1s/oh-lucy.nvim",
		config = function()
			-- vim.cmd.colorscheme("oh-lucy")
		end,
	},
}
