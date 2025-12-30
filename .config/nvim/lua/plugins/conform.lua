local function get_formatters(bufnr)
	local root = vim.fn.getcwd()

	-- Check for oxfmt configuration
	if vim.fn.glob(root .. "/.oxfmtrc*") ~= "" then
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

	-- Fallback to both
	return { "biome", "prettierd", "prettier" }
end

return {
	"stevearc/conform.nvim",
	tag = "v8.4.0",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			sql = { "sqlfluff" },
			javascript = get_formatters,
			typescript = get_formatters,
			typescriptreact = get_formatters,
		},
	},
}
