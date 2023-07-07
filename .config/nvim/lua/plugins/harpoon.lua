return {
	"theprimeagen/harpoon",
	config = function()
		local nmap = function(keys, func, desc)
			if desc then
				desc = "Harpoon: " .. desc
			end
			vim.keymap.set("n", keys, func, { noremap = true, silent = true, desc = desc })
		end

		nmap("<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>", "[A]dd file to harpoon")
		nmap("<leader>hl", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", "[H]arpoon [L]ist")
		nmap("<leader>hq", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", "Harpoon file 1")
		nmap("<leader>hw", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", "Harpoon file 2")
		nmap("<leader>he", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", "Harpoon file 3")
		nmap("<leader>hf", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", "Harpoon file 3")
		nmap("<leader>hr", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", "Harpoon file 4")
		nmap("<leader>hp", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", "Harpoon file 4")
	end,
}
