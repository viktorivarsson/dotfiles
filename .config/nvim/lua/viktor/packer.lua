-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- faster loading
    use ("lewis6991/impatient.nvim")

    -- center
    use("smithbm2316/centerpad.nvim")

    -- packer can manage itself
    use("wbthomason/packer.nvim")

    -- theme
    use("sam4llis/nvim-tundra")
    use("folke/tokyonight.nvim")

    -- treesitter
    use({
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    })
    use("nvim-treesitter/nvim-treesitter-context")

    use("kyazdani42/nvim-web-devicons")

    use("ThePrimeagen/git-worktree.nvim")


    -- status line
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons" }
    })

    use('lewis6991/gitsigns.nvim')

    use("petertriho/nvim-scrollbar")

    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "rouge8/neotest-rust",
            "haydenmeade/neotest-jest",
        }
    }

    -- surround --
    use({
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })


    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup({
                position = "right",
            })
        end
    }

    -- telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        requires = { {'nvim-lua/plenary.nvim'}, {'BurntSushi/ripgrep' }}
    }

    -- toggle term
    use("akinsho/toggleterm.nvim")

    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    })

    -- lsp
    use("neovim/nvim-lspconfig")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-nvim-lsp-signature-help")
    use("hrsh7th/cmp-path")
    use("hrsh7th/nvim-cmp")
    use{'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
    use("onsails/lspkind-nvim")
    use("nvim-lua/lsp_extensions.nvim")
    use("glepnir/lspsaga.nvim")
    use("simrat39/symbols-outline.nvim")
    use("L3MON4D3/LuaSnip")
    use("saadparwaiz1/cmp_luasnip")

    -- format
    use("sbdchd/neoformat")
end)
