return {
	"folke/zen-mode.nvim",
	event = "VeryLazy",
	config = function()
		require("zen-mode").setup({})

		local map = vim.api.nvim_set_keymap

		map("n", "<leader>z", ":ZenMode<cr>", { noremap = true, silent = true, desc = "[Z]en Mode" })
	end,
}
