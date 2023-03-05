return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"jcdickinson/wpm.nvim",
		"kyazdani42/nvim-web-devicons",
	},
	config = function()
		local wpm = require("wpm")

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "sonokai",
			},
			sections = {
				lualine_a = { "branch" },
				lualine_b = { "diff", "diagnostics", "searchcount" },
				lualine_c = { { "filename", file_status = true, path = 1 } },
				lualine_x = { "filetype" },
				lualine_y = { wpm.wpm, wpm.historic_graph, "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", file_status = true, path = 1 } },
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
		})
	end,
}
