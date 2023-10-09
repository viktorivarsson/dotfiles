return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {},
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = false,
				sync_install = false,
				highlight = { enable = true },
				ensure_installed = {},
				ignore_install = {},
				modules = {},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<c-space>",
						node_incremental = "<c-space>",
						scope_incremental = "<c-s>",
						node_decremental = "<c-backspace>",
					},
				},
			})
		end,
	},
}
