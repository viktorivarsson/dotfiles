local map = vim.api.nvim_set_keymap

-- Map leader
map("n", "<space>", "", {})
vim.g.mapleader = " "  -- 'vim.g' sets global variables

options = { noremap = true }

map("n", "<leader>pv", ":Ex<cr>", options)

-- Move lines up / down
map("v", "J", ":m '>+1<cr>gv=gv", options)
map("v", "K", ":m '<-2<cr>gv=gv", options)

map("x", "<leader>p", "\"_dP", options)

-- Edit VIM
map("n", "<leader>1", ":e $MYVIMRC<cr>", options)
map("n", "<leader>2", ":source $MYVIMRC<cr>", options)

-- Save and exit shortcuts
map("n", "<leader>w", ":w!<cr>", options)
map("n", "<leader>q", ":q!<cr>", options)

-- Buffers
map("n", "<leader>bd", ":bd<cr>", options)
map("n", "<leader>bb", ":buffers<cr>", options)

-- Telescope
map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", options)
map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", options)
map("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", options)
map("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", options)

-- LSP
map("n", "<leader>vd", ":lua vim.lsp.buf.definition()<cr>", options)
map("n", "<leader>vi", ":lua vim.lsp.buf.implementation()<cr>", options)
map("n", "<leader>vsh", ":lua vim.lsp.buf.signature_help()<cr>", options)
map("n", "<leader>vrr", ":lua vim.lsp.buf.references()<cr>", options)
map("n", "<leader>vrn", ":lua vim.lsp.buf.rename()<cr>", options)
map("n", "<leader>vh", ":lua vim.lsp.buf.hover()<cr>", options)
map("n", "<leader>vca", ":lua vim.lsp.buf.code_action()<cr>", options)
map("n", "<leader>vsd", ":lua vim.lsp.buf.diagnostic.show_line_diagnostics()<cr>", options)
map("n", "<leader>vn", ":lua vim.lsp.buf.diagnostic.goto_next()<cr>", options)
map("n", "<leader>vll", ":call LspLocationList()<cr>", options)
map("n", "<leader>dn", ":Lspsaga diagnostic_jump_next<cr>", options)
map("n", "<leader>dp", ":Lspsaga diagnostic_jump_prev<cr>", options)
map("n", "<leader>dc", ":Lspsaga show_cursor_diagnostics<cr>", options)

