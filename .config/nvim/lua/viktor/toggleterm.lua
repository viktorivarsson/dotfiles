local map = vim.api.nvim_set_keymap

require("toggleterm").setup({
	size = 80,
	open_mapping = [[<c-t>]],
	direction = "vertical",
})

function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

