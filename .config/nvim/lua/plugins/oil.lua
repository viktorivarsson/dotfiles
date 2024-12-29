return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "kyazdani42/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      },
    })

    local map = vim.api.nvim_set_keymap

    map("n", "<leader>.", ":Oil<cr>", { noremap = true, silent = true, desc = "Oil (Project View)" })
  end,
}
