return {
	"metakirby5/codi.vim",

	-- theme
	"sam4llis/nvim-tundra",
	"folke/tokyonight.nvim",

  {

  },

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},

	"kyazdani42/nvim-web-devicons",

	-- status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
	},

	"lewis6991/gitsigns.nvim",

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
}
