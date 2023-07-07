return {
	"windwp/nvim-spectre",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = function()
		local map = vim.api.nvim_set_keymap
		local options = { noremap = true, silent = true }

		map("n", "<leader>S", "<cmd>lua require('spectre').open()<cr>", options)

		-- Search current word
		map("n", "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", options)

		-- Search in current file
		map("n", "<leader>sp", "<cmd>lua require('spectre').open_file_search()<cr>", options)

		require("spectre").setup()
	end,
}
