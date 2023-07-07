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

			local nmap = function(keys, func, desc)
				if desc then
					desc = "Telescope: " .. desc
				end
				vim.keymap.set("n", keys, func, { desc = desc })
			end

			nmap("<leader>ff", builtin.find_files, "[F]ind [F]iles")
			nmap("<leader>fg", builtin.live_grep, "[F]ind [G]rep")
			nmap("<leader>fh", builtin.help_tags, "[F]ind [H]elp")
			nmap("<leader>gr", builtin.lsp_references, "[G]oto [R]eferences")
			nmap("<leader>fb", builtin.buffers, "[F]ind [B]uffers")
			nmap("<leader>ft", builtin.treesitter, "[F]ind [T]reesitter")
			nmap("<leader>fk", builtin.keymaps, "[F]ind [K]eymaps")

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
