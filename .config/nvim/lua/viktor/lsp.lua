local ok, lsp = pcall(require, "lsp-zero")

if not ok then
	return
end

local nvim_lsp = require("lspconfig")
local cmp = require("cmp")

lsp.preset("recommended")

lsp.ensure_installed({
	"eslint",
	"rust_analyzer",
	"sumneko_lua",
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

local function lsp_keymaps(bufnr)
	local map = function(m, lhs, rhs)
		local opts = { remap = false, silent = true, buffer = bufnr }
		vim.keymap.set(m, lhs, rhs, opts)
	end

	-- LSP actions
	map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
	map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
	map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
	map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
	map("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
	map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")
	map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
	map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
	map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>")
	map("x", "<F4>", "<cmd>lua vim.lsp.buf.range_code_action()<cr>")

	-- Diagnostics
	map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
	map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
	map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")
end

local function lsp_attach(client, bufnr)
	local buf_command = vim.api.nvim_buf_create_user_command

	lsp_keymaps(bufnr)

	buf_command(bufnr, "LspFormat", function()
		vim.lsp.buf.format()
	end, { desc = "Format buffer with language server" })
end

require("mason-lspconfig").setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			on_attach = lsp_attach,
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})
	end,
})

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
})

require("luasnip.loaders.from_snipmate").lazy_load()

lsp.setup()
