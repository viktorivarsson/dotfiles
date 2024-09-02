return {
  {
    "nvim-telescope/telescope.nvim",
    keys = function()
      return {
        {
          "<leader>,",
          "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
          desc = "Switch Buffer",
        },
        { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
        { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
        -- find
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
        { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
        { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
        { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
        { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
        { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
        { "<leader>fR", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
        -- git
        { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
        -- { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
        -- search
        { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
        { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
        { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
        { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
        { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
        { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
        { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
        { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
        { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
        { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
        { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
        { "<leader>sw", LazyVim.pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
        { "<leader>sW", LazyVim.pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
        { "<leader>sw", LazyVim.pick("grep_string", { root = false }), mode = "v", desc = "Selection (cwd)" },
        { "<leader>sW", LazyVim.pick("grep_string"), mode = "v", desc = "Selection (Root Dir)" },
        {
          "<leader>uC",
          LazyVim.pick("colorscheme", { enable_preview = true }),
          desc = "Colorscheme with Preview",
        },
        {
          "<leader>ss",
          function()
            require("telescope.builtin").lsp_document_symbols({
              symbol_width = 50,
              symbols = {
                "variable",
                "function",
                "constant",
                "method",
                "struct",
                "class",
                "interface",
                "enum",
                "module",
                "typeParameter",
              },
            })
          end,
          desc = "Goto Symbol",
        },
        {
          "<leader>sS",
          function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols({
              symbols = require("lazyvim.config").get_kind_filter(),
            })
          end,
          desc = "Goto Symbol (Workspace)",
        },
      }
    end,
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<C-f>"] = require("telescope.actions").preview_scrolling_down,
            ["<c-d>"] = require("telescope.actions").delete_buffer,
            ["<C-q>a"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
            ["<C-q>s"] = require("telescope.actions").send_selected_to_qflist
              + require("telescope.actions").open_qflist,
          },
          n = {
            ["<C-f>"] = require("telescope.actions").preview_scrolling_down,
            ["<c-d>"] = require("telescope.actions").delete_buffer,
          },
        },
      },
    },
  },
}
