return {
	{
		"tpope/vim-fugitive",

		config = function()
			local map = vim.api.nvim_set_keymap

			map("n", "<leader>gs", "<cmd>Git<cr>", {})
		end,
	},
}
