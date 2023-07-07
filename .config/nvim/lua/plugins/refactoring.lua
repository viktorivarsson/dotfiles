return {
	"ThePrimeagen/refactoring.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("refactoring").setup({})

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true, expr = false }

		map("v", "<leader>rr", ":lua require('refactoring').select_refactor()<cr>", opts)
	end,
}
