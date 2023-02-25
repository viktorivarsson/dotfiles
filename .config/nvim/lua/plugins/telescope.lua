return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-lua/plenary.nvim" },
			{ "BurntSushi/ripgrep" },
		},
		config = function()
			local telescope = require("telescope")
			local telescope_config = require("telescope.config")

			local map = vim.api.nvim_set_keymap

			local options = { noremap = true }
			map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", options)
			map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", options)
			map("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", options)
			map("n", "<leader>gr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", options)
			map("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", options)
			map("n", "<leader>ft", "<cmd>lua require('telescope.builtin').treesitter()<cr>", options)
			map("n", "<leader>fk", "<cmd>lua require('telescope.builtin').keymaps()<cr>", options)

			-- Clone the default Telescope configuration
			local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
			table.insert(vimgrep_arguments, "--hidden")
			table.insert(vimgrep_arguments, "--glob")
			table.insert(vimgrep_arguments, "!.git/*")

			telescope.setup({
				defaults = {
					file_ignore_patterns = { "node_modules", "yarn.lock", ".git", ".bin" },
					vimgrep_arguments = vimgrep_arguments,
					path_display = {
						truncate = 3,
					},
				},
				pickers = {
					buffers = {
						sort_mru = true,
						theme = "ivy",
						mappings = {
							i = {
								["<c-d>"] = "delete_buffer",
							},
						},
					},
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*", "--glob", "!.bin/*" },
						theme = "ivy",
					},
					live_grep = {
						theme = "ivy",
					},
					help_tags = {
						theme = "ivy",
					},
					lsp_references = {
						theme = "ivy",
					},
					treesitter = {
						theme = "ivy",
					},
				},
			})

			telescope.load_extension("fzf")
		end,
	},
}
