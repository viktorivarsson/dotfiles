local function get_formatters(bufnr)
  local root = vim.fn.getcwd()

  -- Check for oxfmt config
  if vim.fn.glob(root .. "/.oxfmtrc.json") ~= "" or vim.fn.glob(root .. "/.oxfmtrc.jsonc") ~= "" then
    return { "oxfmt" }
  end

  -- Check for biome.json or biome configuration
  if
    vim.fn.glob(root .. "/biome.json") ~= ""
    or vim.fn.glob(root .. "/biome.jsonc") ~= ""
    or vim.fn.glob(root .. "/.biomerc") ~= ""
  then
    return { "biome" }
  end

  -- Check for prettier configuration
  if
    vim.fn.glob(root .. "/.prettierrc*") ~= ""
    or vim.fn.glob(root .. "/prettier.config.*") ~= ""
    or vim.fn.glob(root .. "/package.json") ~= ""
  then
    return { "prettierd", "prettier" }
  end

  -- Fallback to all
  return { "oxfmt", "biome", "prettierd", "prettier" }
end

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sql = { "sqlfluff" },
      javascript = get_formatters,
      typescript = get_formatters,
      typescriptreact = get_formatters,
    },
  },
}
