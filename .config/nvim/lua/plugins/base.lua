return {
  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  --
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin",
      colorscheme = "onedark",
    },
  },

  -- {
  --   "catppuccin",
  --   priority = 1000,
  --   lazy = false,
  --   opts = {
  --     transparent_background = true,
  --   },
  -- },

  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        style = "darker",
      })
      require("onedark").load()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
        "graphql",
        "svelte",
      })
    end,
  },
}
