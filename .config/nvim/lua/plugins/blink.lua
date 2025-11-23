return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",

      -- Disable Tab completely (Sidekick NES will handle it)
      ["<Tab>"] = {},
      ["<S-Tab>"] = {},

      -- Disable Enter
      ["<CR>"] = {},

      -- Manual trigger with Ctrl-Space (blink default)
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

      -- Navigate with Ctrl-n/Ctrl-p when menu is open
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },

      -- Accept with Ctrl-y
      ["<C-y>"] = { "accept", "fallback" },
    },
    completion = {
      menu = {
        border = "rounded",
        winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
      },
      documentation = {
        window = {
          border = "rounded",
        },
      },
    },
  },
}
