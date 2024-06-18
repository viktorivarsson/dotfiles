return {
  "github/copilot.vim",
  enabled = false,
  config = function()
    vim.g.copilot_no_tab_map = true

    local map = vim.api.nvim_set_keymap
    map("i", "<c-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    map("i", "<c-n>", "<plug>(copilot-previous)", { silent = true })
    map("i", "<c-p>", "<plug>(copilot-previous)", { silent = true })
  end,
}
