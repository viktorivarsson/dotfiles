return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
		})

		local map = vim.api.nvim_set_keymap

		map("n", "<leader>pv", ":Oil<cr>", { noremap = true, silent = true, desc = "[P]roject [V]iew" })
	end,
}
