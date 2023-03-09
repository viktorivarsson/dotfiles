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
			local builtin = require("telescope.builtin")
			local actions = require("telescope.actions")
			local map = vim.keymap.set

			local options = { noremap = true }

			map("n", "<leader>ff", builtin.find_files, options)
			map("n", "<leader>fg", builtin.live_grep, options)
			map("n", "<leader>fh", builtin.help_tags, options)
			map("n", "<leader>gr", builtin.lsp_references, options)
			map("n", "<leader>fb", builtin.buffers, options)
			map("n", "<leader>ft", builtin.treesitter, options)
			map("n", "<leader>fk", builtin.keymaps, options)
			map("n", "<leader>fk", builtin.keymaps, options)

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
					mappings = {
						i = {
							["<c-q>a"] = actions.send_to_qflist + actions.open_qflist,
							["<c-q>s"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
						n = {
							["<c-q>a"] = actions.send_to_qflist + actions.open_qflist,
							["<c-q>s"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
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
