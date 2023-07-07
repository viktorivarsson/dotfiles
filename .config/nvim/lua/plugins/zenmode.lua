return {
	"folke/zen-mode.nvim",
	event = "VeryLazy",
	config = function()
		require("zen-mode").setup({})

		local map = vim.api.nvim_set_keymap
		local options = { noremap = true, silent = true }

		map("n", "<leader>z", ":ZenMode<cr>", options)
	end,
}
