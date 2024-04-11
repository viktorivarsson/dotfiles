return {
  "L3MON4D3/LuaSnip",
  keys = function()
    return {
      {
        "]l",
        function()
          require("luasnip").jump(1)
        end,
        mode = { "v", "n" },
        desc = "Jump to next snippet",
      },
      {
        "[l",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "v", "n" },
        desc = "Jump to previous snippet",
      },
    }
  end,
}
