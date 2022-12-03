local map = vim.api.nvim_set_keymap

vim.g.copilot_no_tab_map = true

local options = { noremap = true, silent = true }

map("n", "<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>", options)
map("n", "<c-e>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", options)
map("n", "<leader>h1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", options)
map("n", "<leader>h2", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", options)
map("n", "<leader>h3", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", options)
map("n", "<leader>h4", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", options)
