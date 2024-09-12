return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-jest", "marilari88/neotest-vitest", "nvim-neotest/neotest-go" },
    opts = function(_, opts)
      table.insert(opts.adapters, require("neotest-jest"))
      table.insert(opts.adapters, require("neotest-vitest"))
      table.insert(opts.adapters, require("neotest-go"))
    end,
  },
}
