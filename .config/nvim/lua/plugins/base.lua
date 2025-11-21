return {
  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  --
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      transparent_background = true,
    },
  },

  -- change some telescope options and a keymap to browse plugin files

  -- { import = "lazyvim.plugins.extras.lang.typescript" },

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

  -- -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  -- { import = "lazyvim.plugins.extras.lang.json" },
}
