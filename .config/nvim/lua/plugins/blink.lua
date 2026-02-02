return {
  "saghen/blink.cmp",
  opts = {
    -- Blink/CMP will provide completion dropdowns. cmp's experimental ghost_text
    -- is disabled globally (via a small optional cmp config) so Copilot remains
    -- the single inline/ghost suggestion provider.
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

      -- Accept with Ctrl-y (dropdown accept)
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
