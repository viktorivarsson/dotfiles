return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.mapping["<CR>"] = nil
    opts.experimental.ghost_text = false
  end,
}
