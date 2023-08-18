return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	config = function()
		require("lsp_lines").setup()

		vim.diagnostic.config({
			virtual_text = false,
		})

		local map = vim.api.nvim_set_keymap

		map(
			"n",
			"<leader>1",
			':lua require("lsp_lines").toggle()<cr>',
			{ noremap = true, silent = true, desc = "Toggle lsp_lines" }
		)
	end,
}
