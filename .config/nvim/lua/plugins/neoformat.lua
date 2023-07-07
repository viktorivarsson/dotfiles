return {
	"sbdchd/neoformat",
	event = "VeryLazy",
	config = function()
		local map = vim.api.nvim_set_keymap

		map("n", "<leader>fa", "<cmd>Neoformat<cr>", { noremap = true, silent = true, desc = "[F]ormat [A]ll" })
	end,
}
