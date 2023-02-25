return {
	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
		cmd = "TroubleToggle",
		config = function()
			local map = vim.api.nvim_set_keymap
			local options = { noremap = true, silent = true }

			map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", options)
			map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", options)
			map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", options)
		end,
	},
}
