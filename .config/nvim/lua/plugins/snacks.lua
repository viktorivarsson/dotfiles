local default_excludes = {
  "**/dist/*",
  "**/node_modules/*",
  "**/.git/*",
  "**/build/*",
  "**/*.log",
  "**/coverage/*",
  "**/__generated__/*",
  "**/public/*",
  "**/.svelte-kit/*",
  "**/.vscode/*",
  "**/yarn.lock",
  "**/.data/*",
  "**/.cache/*",
  "**/routeTree.gen.ts",
  "**/bun.lock",
  "**/generated/",
}

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = default_excludes,
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = default_excludes,
        },
      },
    },
  },
  keys = {
    {
      "<leader>.",
      nil,
    },
    {
      "<leader>fs",
      function()
        local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        Snacks.scratch({ file = "~/.local/share/nvim/snacks/scratch/" .. dir_name .. ".md" })
      end,
      desc = "Toggle Directory Scratch Buffer",
    },
    {
      "<leader>fS",
      function()
        Snacks.scratch({ file = "~/.local/share/nvim/snacks/scratch/global.md" })
      end,
      desc = "Toggle Global Scratch Buffer",
    },
    -- Enhanced search keymaps
    {
      "<leader>sg",
      function()
        Snacks.picker.grep({
          hidden = true,
          ignored = true,
          exclude = default_excludes,
          layout = { preset = "vertical" },
        })
      end,
      desc = "[S]earch [G]rep (including hidden files)",
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.files({
          hidden = true,
          ignored = true,
          exclude = default_excludes,
        })
      end,
      desc = "[S]earch [F]iles (including hidden files)",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps({ layout = { preset = "vertical" } })
      end,
      desc = "[S]earch [K]eymaps",
    },
  },
}
