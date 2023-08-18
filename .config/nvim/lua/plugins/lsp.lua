local cmp_kinds = {
	Text = "  ",
	Method = "  ",
	Function = "  ",
	Constructor = "  ",
	Field = "  ",
	Variable = "  ",
	Class = "  ",
	Interface = "  ",
	Module = "  ",
	Property = "  ",
	Unit = "  ",
	Value = "  ",
	Enum = "  ",
	Keyword = "  ",
	Snippet = "  ",
	Color = "  ",
	File = "  ",
	Reference = "  ",
	Folder = "  ",
	EnumMember = "  ",
	Constant = "  ",
	Struct = "  ",
	Event = "  ",
	Operator = "  ",
	TypeParameter = "  ",
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- lsp
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "j-hui/fidget.nvim" },
			{ "folke/neodev.nvim" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },

			-- completion
			{
				"hrsh7th/nvim-cmp",
				dependencies = {
					{ "hrsh7th/cmp-nvim-lsp" },
					-- snippets
					{ "saadparwaiz1/cmp_luasnip" },
					{ "L3MON4D3/LuaSnip" },
					{ "rafamadriz/friendly-snippets" },
				},
			},
		},
		config = function()
			vim.keymap.set("n", "<leader>cm", ":Mason<cr>", { noremap = true, silent = true, desc = "Open Mason" })

			local on_attach = function(_, bufnr)
				local nmap = function(keys, func, desc)
					if desc then
						desc = "LSP: " .. desc
					end

					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				nmap("K", vim.lsp.buf.hover, "Hover Documentation")
				nmap("<c-k>", vim.lsp.buf.signature_help, "Signature Documentation")
				nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
				nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
				nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				nmap("gl", vim.diagnostic.open_float, "[G]o to Diagnostic [L]ist")
				nmap("[d", vim.diagnostic.goto_prev, "Previous [D]iagnostic")
				nmap("]d", vim.diagnostic.goto_next, "Next [D]iagnostic")

				vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })
			end

			require("mason").setup()
			require("neodev").setup()

			local nvim_lsp = require("lspconfig")

			local servers = {
				eslint = {},
				tsserver = {
					root_dir = nvim_lsp.util.root_pattern("package.json"),
					single_file_support = false,
				},
				cssls = {},
				denols = {
					root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
				},
				graphql = {},
				html = {},
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
			})

			local function merge(t1, t2)
				local result = {}
				for k, v in pairs(t1) do
					result[k] = v
				end
				for k, v in pairs(t2) do
					result[k] = v
				end
				return result
			end

			local static_config = {
				on_attach = on_attach,
				capabilities = capabilities,
			}

			mason_lspconfig.setup_handlers({
				function(server_name)
					if servers[server_name] then
						nvim_lsp[server_name].setup(merge(static_config, servers[server_name]))
					else
						nvim_lsp[server_name].setup(static_config)
					end
				end,
			})

			local luasnip = require("luasnip")
			require("luasnip.loaders.from_snipmate").lazy_load()
			luasnip.config.setup({})

			local cmp = require("cmp")
			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					format = function(_, vim_item)
						vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
						return vim_item
					end,
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<c-y>"] = cmp.mapping.confirm({ select = false }),
					["<c-n>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item(cmp_select)
						else
							fallback()
						end
					end,
					["<down>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item(cmp_select)
						else
							fallback()
						end
					end,
					["<c-p>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item(cmp_select)
						else
							fallback()
						end
					end,
					["<up>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item(cmp_select)
						else
							fallback()
						end
					end,
					["<c-space>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.close()
						else
							cmp.complete()
						end
					end),
				}),
				sources = {
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lsp", keyword_length = 3 },
					{ name = "buffer", keyword_length = 3 },
					{ name = "luasnip", keyword_length = 2 },
				},
			})
		end,
	},
}
