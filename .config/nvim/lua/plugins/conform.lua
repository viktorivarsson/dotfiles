local js = { { "biome", "prettierd", "prettier" } }

return {
  "stevearc/conform.nvim",
  tag = "v8.4.0",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      sql = { "sqlfluff" },
      javascript = js,
      typescript = js,
      typescriptreact = js,
    },
  },
}
