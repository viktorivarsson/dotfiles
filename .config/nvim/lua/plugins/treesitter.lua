return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = false,
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
				-- enable autotagging (w/ nvim-ts-autotag plugin)
				autotag = {
					enable = true,
				},
				ensure_installed = {
					"bash",
					"css",
					"dockerfile",
					"elixir",
					"gitignore",
					"graphql",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"ocaml",
					"prisma",
					"rust",
					"svelte",
					"toml",
					"tsx",
					"typescript",
					"yaml",
				},
				ignore_install = {},
				modules = {},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<c-space>",
						node_incremental = "<c-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
				context_commentstring = {
					enable = true,
					enable_autocmd = false,
				},
			})
		end,
	},
}
