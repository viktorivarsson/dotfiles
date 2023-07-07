return {
	"nvim-pack/nvim-spectre",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = function()
		local nmap = function(keys, func, desc)
			if desc then
				desc = "Spectre: " .. desc
			end
			vim.keymap.set("n", keys, func, { noremap = true, silent = true, desc = desc })
		end

		nmap("<leader>S", "<cmd>lua require('spectre').open()<cr>", "Open [S]pectre")

		-- Search current word
		nmap("<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "[S]earch current [W]ord")

		-- Search in current file
		nmap("<leader>sp", "<cmd>lua require('spectre').open_file_search()<cr>", "Search in current file")

		require("spectre").setup()
	end,
}
