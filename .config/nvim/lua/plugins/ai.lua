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
      -- NES Tab behavior
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
      -- AI group
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      -- Toggle Sidekick CLI
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      -- Select CLI
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Select CLI",
      },
      -- Detach CLI
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      -- Send this
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      -- Send file
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      -- Send visual selection
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      -- Select prompt
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      -- Toggle NES
      {
        "<leader>ae",
        function()
          require("sidekick.nes").toggle()
        end,
        desc = "Toggle Sidekick NES",
      },
      -- Request NES suggestions
      {
        "<leader>ar",
        function()
          require("sidekick.nes").update()
        end,
        desc = "Request NES suggestions",
      },
      -- Explain this
      {
        "<leader>ah",
        function()
          require("sidekick.cli").send({ msg = "Explain {this}" })
        end,
        desc = "Explain this",
      },
      -- Fix this
      {
        "<leader>ai",
        function()
          require("sidekick.cli").send({ msg = "Can you fix {this}?" })
        end,
        desc = "Fix this",
      },
      -- Review file
      {
        "<leader>aj",
        function()
          require("sidekick.cli").send({ msg = "Can you review {file} for any issues or improvements?" })
        end,
        desc = "Review file",
      },
      -- Optimize this
      {
        "<leader>ak",
        function()
          require("sidekick.cli").send({ msg = "How can {this} be optimized?" })
        end,
        desc = "Optimize this",
      },
      -- Add documentation
      {
        "<leader>al",
        function()
          require("sidekick.cli").send({ msg = "Add documentation to {function|line}" })
        end,
        desc = "Add documentation",
      },
      -- Write tests
      {
        "<leader>am",
        function()
          require("sidekick.cli").send({ msg = "Can you write tests for {this}?" })
        end,
        desc = "Write tests",
      },
      -- Fix diagnostics
      {
        "<leader>ao",
        function()
          require("sidekick.cli").send({ msg = "Can you help me fix the diagnostics in {file}?\n{diagnostics}" })
        end,
        desc = "Fix diagnostics",
      },
      -- Review changes
      {
        "<leader>aq",
        function()
          require("sidekick.cli").send({
            msg = "Review changes: show uncommitted diffs if on main branch, otherwise diff against main",
          })
        end,
        desc = "Review changes",
      },
    },
    config = function()
      -- Ensure default setup is applied
      require("sidekick").setup()
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
