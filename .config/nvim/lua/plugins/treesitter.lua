return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					-- `false` will disable the whole extension
					enable = true,
				},
			})
		end,
	},
}
