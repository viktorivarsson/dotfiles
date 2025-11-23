return {
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    opts = {
      -- NES (Native Edit Suggestions) configuration
      nes = {
        enabled = true,
        provider = "copilot",
      },
      -- Optional: CLI assistant
      cli = {
        enabled = true,
      },
    },
    -- Keep NES Tab behavior in normal mode (jump/apply). Do not override insert-mode Tab here.
    keys = {
      {
        "<Tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
        mode = { "n" },
      },
      -- Toggle Sidekick CLI
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Toggle Sidekick CLI",
        mode = { "n", "v" },
      },
      -- Toggle NES on/off
      {
        "<leader>ae",
        function()
          require("sidekick.nes").toggle()
        end,
        desc = "Toggle Sidekick NES",
      },
      -- Manually request new suggestions
      {
        "<leader>ar",
        function()
          require("sidekick.nes").update()
        end,
        desc = "Request NES suggestions",
      },
    },
    config = function()
      -- Ensure default setup is applied
      require("sidekick").setup()

      -- -- Guaranteed literal tab fallbacks (terminal may not send <C-Tab>)
      -- vim.keymap.set("i", "<C-Tab>", function()
      --   local term_tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      --   vim.api.nvim_feedkeys(term_tab, "n", true)
      -- end, { silent = true, noremap = true, desc = "Insert literal tab" })
      -- vim.keymap.set("i", "<leader><Tab>", function()
      --   local term_tab = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      --   vim.api.nvim_feedkeys(term_tab, "n", true)
      -- end, { silent = true, noremap = true, desc = "Insert literal tab (fallback)" })
    end,
  },

  -- Copilot: keep inline suggestions, but remove Alt-based accept mappings and provide Ctrl alternatives
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-j>",
          accept_word = false,
          accept_line = false,
          next = false,
          prev = false,
          dismiss = false,
        },
      },
      panel = {
        enabled = true,
        auto_refresh = false,
      },
    },
  },
}
