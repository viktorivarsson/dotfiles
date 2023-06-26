return {
	"m4xshen/hardtime.nvim",
	event = "VeryLazy",
	opts = {
		restricted_keys = {
			["h"] = { "n", "v" },
			["j"] = { "n", "v" },
			["k"] = { "n", "v" },
			["l"] = { "n", "v" },
			["<up>"] = { "n", "v" },
			["<down>"] = { "n", "v" },
			["<left>"] = { "n", "v" },
			["<right>"] = { "n", "v" },
			["<cr>"] = { "n", "v" },
		},
		disabled_keys = {},
		disabled_filetypes = { "qf", "oil", "lazy", "mason" },
	},
}
