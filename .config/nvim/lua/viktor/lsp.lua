local ok, lsp = pcall(require, "lsp-zero")

if not ok then
	return
end

local nvim_lsp = require("lspconfig")
local cmp = require("cmp")

lsp.preset("recommended")

lsp.on_attach(function(client, bufnr)
	local map = vim.keymap.set
	local options = { buffer = bufnr, remap = false, silent = true }

	-- LSP
	map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", options)
	map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", options)
	map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", options)
	map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", options)
	map("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", options)
	map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", options)
	map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", options)
	map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", options)
	map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", options)

	-- Diagnostics
	map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", options)
	map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", options)
	map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", options)
end)

local cmp_select = { behavior = cmp.SelectBehavior.Select }

lsp.setup_nvim_cmp({
	mapping = {
		["<cr>"] = cmp.mapping.confirm({ select = false }),
		["<c-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<c-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<c-space>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.close()
				fallback()
			else
				cmp.complete()
			end
		end),
	},
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "nvim_lsp", keyword_length = 3 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
	},
})

lsp.ensure_installed({
	"eslint",
	"rust_analyzer",
	"tsserver",
	"cssls",
	"denols",
	"graphql",
	"html",
	"tailwindcss",
})

lsp.configure("tsserver", {
	root_dir = nvim_lsp.util.root_pattern("package.json"),
})

lsp.configure("denols", {
	root_dir = nvim_lsp.util.root_pattern("deno.json"),
})

lsp.configure("sumneko_lua", {
	settings = {
		Lua = {
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
		},
	},
})

require("luasnip.loaders.from_snipmate").lazy_load()

lsp.nvim_workspace()
lsp.setup()
