return {
  "snacks.nvim",
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
  },
}
