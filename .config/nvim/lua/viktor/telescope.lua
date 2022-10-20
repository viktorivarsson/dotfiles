local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local telescope_config = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!.git/*")

require("telescope").setup({
	defaults = {
		file_ignore_patterns = { "node_modules", "yarn.lock", ".git" },
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
			find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
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

require("telescope").load_extension("git_worktree")
