return {
	{
		"folke/tokyonight.nvim",
		config = function()
			-- vim.cmd([[set background=dark]])
			-- vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{

		"sainnhe/sonokai",
		config = function()
			vim.g.sonokai_style = "andromeda"
			vim.g.sonokai_better_performance = 1
			vim.cmd([[colorscheme sonokai]])
		end,
	},
	{
		"arcticicestudio/nord-vim",
		config = function()
			-- vim.cmd([[set background=dark]])
			-- vim.cmd([[colorscheme nord]])
		end,
	},
	{
		"cocopon/iceberg.vim",
		config = function()
			-- vim.cmd([[set background=dark]])
			-- vim.cmd([[colorscheme iceberg]])
		end,
	},
}
