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
map("v", "<leader>y", "\"*y", options)

-- Edit VIM
map("n", "<leader>1", ":e $MYVIMRC<cr>", options)
map("n", "<leader>2", ":lua reload_nvim_conf()<cr>", options)

-- Zenmode
map("n", "<leader>z", ":ZenMode<cr>", { noremap = true, silent = true })


-- Save and exit shortcuts
map("n", "<leader>w", ":w!<cr>", options)
map("n", "<leader>q", ":q!<cr>", options)

-- Buffers
map("n", "<leader>bd", ":bd<cr>", options)
map("n", "<leader>bb", ":buffers<cr>", options)

-- Telescope
map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", options)
map("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", options)
map("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", options)
map("n", "<leader>gr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", options)
map("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", options)
map("n", "<leader>ft", "<cmd>lua require('telescope.builtin').treesitter()<cr>", options)
map("n", "<leader>gwc", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", options)
map("n", "<leader>gwl", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", options)

-- Trouble
local options = { silent = true, noremap = true }
map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", options)
map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", options)
map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", options)
map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", options)
map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", options)
map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", options)

-- Formatting
map("n", "<leader>fa", "<cmd>Neoformat<cr>", { silent = true, noremap = true })

-- Lazy Git
map("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<cr>", {})
