local map = vim.api.nvim_set_keymap

local options = { noremap = true }
local silent_options = { noremap = true, silent = true }

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "[L]azy" })

-- copy relative file path to clipboard
map("n", "<leader>fp", ":let @+ = expand('%')<cr>", { desc = "Copy relative [F]ile [P]ath to clipboard" })

-- Move lines up / down
map("v", "J", ":m '>+1<cr>gv=gv", options)
map("v", "K", ":m '<-2<cr>gv=gv", options)
map("v", "<s-down>", ":m '>+1<cr>gv=gv", options)
map("v", "<s-up>", ":m '<-2<cr>gv=gv", options)

-- Center after navigation commands
map("n", "<c-d>", "<c-d>zz", silent_options)
map("n", "<c-u>", "<c-u>zz", silent_options)
map("n", "n", "nzz", silent_options)
map("n", "N", "Nzz", silent_options)

-- No hl search
map("n", "<leader>nl", ":nohlsearch<cr>", { desc = "No [H]ighlight [L]ast search", silent = true })

-- Yank and paste
map("x", "<leader>p", '"_dP', options)
map("v", "<leader>y", '"*y', options)

-- Save / quit
map("n", "<leader>q", ":q!<cr>", { desc = "[Q]uit", silent = true })
map("n", "<leader>Q", ":qa!<cr>", { desc = "[Q]uit All", silent = true })
map("n", "<leader>ww", ":update<cr>", { desc = "[W]rite [W]ithout prompt", silent = true })
map("n", "<leader>wq", ":wq<cr>", { desc = "[W]rite [Q]uit", silent = true })

-- Quickfix
map("n", "<leader>cf", ":copen<cr>", { desc = "[C]lose [F]ix", silent = true })
map("n", "<leader>cn", ":cn<cr>", { desc = "Quickfix next", silent = true })
map("n", "<leader>cp", ":cp<cr>", { desc = "Quickfix previous", silent = true })
map("n", "<leader>cN", ":cnew<cr>", { desc = "Quickfix new", silent = true })
map("n", "<leader>cP", ":cold<cr>", { desc = "Quickfix old", silent = true })

-- Buffers
map("n", "<leader>ha", ":b#<cr>", { desc = "[H]op [A]lternate buffer", silent = true })
map("n", "<leader>bd", ":bd<cr>", { desc = "[B]uffer [D]elete", silent = true })
map("n", "<leader>bb", ":buffers<cr>", { desc = "[B]uffer [B]uffer", silent = true })
