return {
	"sbdchd/neoformat",
	config = function()
		local map = vim.api.nvim_set_keymap
		local options = { noremap = true, silent = true }

		map("n", "<leader>fa", "<cmd>Neoformat<cr>", options)
	end,
}
