local map = vim.api.nvim_set_keymap

local options = { noremap = true, siltent = true }

map("n", "<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>", options)
map("n", "<leader>hl", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", options)
map("n", "<leader>hq", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", options)
map("n", "<leader>hw", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", options)
map("n", "<leader>he", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", options)
map("n", "<leader>hr", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", options)
