return {
	{
		"tpope/vim-fugitive",

		config = function()
			local map = vim.api.nvim_set_keymap
			local autocmd = vim.api.nvim_create_autocmd

			map("n", "<leader>gs", "<cmd>Git<cr>", {})

			autocmd("BufWinEnter", {
				pattern = "*",
				callback = function()
					if vim.bo.ft ~= "fugitive" then
						return
					end

					local bufnr = vim.api.nvim_get_current_buf()
					local opts = { buffer = bufnr, remap = false }

					vim.keymap.set("n", "<leader>p", ":Git -c push.default=current push<cr>", opts)

					vim.keymap.set("n", "<leader>P", function()
						vim.cmd.Git({ "pull", "--rebase" })
					end, opts)

					vim.keymap.set("n", "<leader>mm", ":Git merge origin/main<cr>", opts)
				end,
			})
		end,
	},
}
