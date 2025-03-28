return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- disable enter
      ["<CR>"] = {},
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
