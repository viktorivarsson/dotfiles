return {
	{
		"folke/tokyonight.nvim",
		config = function()
			-- vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{
		"Yazeed1s/oh-lucy.nvim",
		config = function()
			-- vim.cmd([[colorscheme oh-lucy]]) -- for oh-lucy
			-- vim.cmd([[colorscheme oh-lucy-evening]]) -- for oh-lucy-evening
		end,
	},
	{
		"olivercederborg/poimandres.nvim",
		config = function()
			require("poimandres").setup({})
			vim.cmd([[colorscheme poimandres]])
		end,
	},
}
