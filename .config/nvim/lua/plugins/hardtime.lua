return {
	"m4xshen/hardtime.nvim",
	event = "VeryLazy",
	opts = {
		max_count = 3,
		restricted_keys = {
			["<up>"] = { "n", "v" },
			["<down>"] = { "n", "v" },
			["<left>"] = { "n", "v" },
			["<right>"] = { "n", "v" },
		},
		disabled_keys = {
			["<UP>"] = {},
			["<RIGHT>"] = {},
			["<DOWN>"] = {},
			["<LEFT>"] = {},
		},
		disabled_filetypes = { "qf", "oil", "lazy", "mason", "Trouble", "undotree" },
	},
}
