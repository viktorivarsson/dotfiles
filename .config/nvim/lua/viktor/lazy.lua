require("lazy").setup({
	"metakirby5/codi.vim",

	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({})
		end,
	},

	{
		"jcdickinson/wpm.nvim",
		config = function()
			require("wpm").setup({})
		end,
	},

	-- theme
	"sam4llis/nvim-tundra",
	"folke/tokyonight.nvim",

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		requires = {
			"windwp/nvim-ts-autotag",
		},
	},

	"kyazdani42/nvim-web-devicons",

	-- status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
	},

	"lewis6991/gitsigns.nvim",

	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({})
		end,
	},

	{
		"folke/trouble.nvim",
		dependencies = "kyazdani42/nvim-web-devicons",
	},

	"nvim-lua/plenary.nvim",

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		dependencies = { { "nvim-lua/plenary.nvim" }, { "BurntSushi/ripgrep" } },
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- harpoon
	"theprimeagen/harpoon",

	"mbbill/undotree",

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	{
		"VonHeikemen/lsp-zero.nvim",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	},

	-- format
	"sbdchd/neoformat",
})
