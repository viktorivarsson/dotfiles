return {
	{
		"folke/trouble.nvim",
		event = "VeryLazy",
		dependencies = "kyazdani42/nvim-web-devicons",
		cmd = "TroubleToggle",
		config = function()
			local nmap = function(keys, func, desc)
				if desc then
					desc = "Trouble: " .. desc
				end
				vim.keymap.set("n", keys, func, { noremap = true, silent = true, desc = desc })
			end

			nmap("<leader>xx", "<cmd>TroubleToggle<cr>", "Toggle")
			nmap("<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace diagnostics")
			nmap("<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", "Document diagnostics")
		end,
	},
}
