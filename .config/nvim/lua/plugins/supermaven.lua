return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      -- keymaps = {
      --   accept_suggestion = "<c-j>",
      --   accept_word = "<c-J>",
      -- },
      color = {
        suggestion_color = "#306569",
        cterm = 244,
      },
      disable_keymaps = true,
    })

    local completion_preview = require("supermaven-nvim.completion_preview")

    vim.keymap.set("i", "<c-j>", completion_preview.on_accept_suggestion, { noremap = true, silent = true })
  end,
}
