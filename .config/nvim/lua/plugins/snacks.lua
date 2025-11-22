return {
  "folke/snacks.nvim",
  opts = {
    picker = {
        sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { "dist/*", "node_modules/*", ".git/*", "build/*", "*.log", "coverage/*", ".svelte-kit/*", ".vscode/*" },
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = { "dist/*", "node_modules/*", ".git/*", "build/*", "*.log", "coverage/*", ".svelte-kit/*", ".vscode/*" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>fs",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>fS",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    -- Enhanced search keymaps
    {
      "<leader>sg",
      function()
        Snacks.picker.grep({ hidden = true, ignored = true, exclude = { "dist/*", "node_modules/*", ".git/*", "build/*", "*.log", "coverage/*" } })
      end,
      desc = "[S]earch [G]rep (including hidden files)",
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.files({ hidden = true, ignored = true, exclude = { "dist/*", "node_modules/*", ".git/*", "build/*", "*.log", "coverage/*" } })
      end,
      desc = "[S]earch [F]iles (including hidden files)",
    },
    
  },
}
