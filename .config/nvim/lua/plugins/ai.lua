local function send_waystone_context(selection, line, column)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Waystone can only send context from a file buffer", vim.log.levels.WARN)
    return
  end

  local command = {
    "waystone",
    "send",
    "--file",
    file,
    "--line",
    tostring(line),
    "--column",
    tostring(column),
  }
  if selection then
    table.insert(command, "--selection")
  end

  vim.system(command, { stdin = selection, text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify(result.stderr:gsub("%s+$", ""), vim.log.levels.ERROR)
      end)
    end
  end)
end

local function enable_waystone_mappings()
  vim.keymap.set("n", "<leader>aw", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    send_waystone_context(nil, cursor[1], cursor[2] + 1)
  end, { desc = "Waystone Send Cursor Context" })

  vim.keymap.set("x", "<leader>aw", function()
    local start = vim.api.nvim_buf_get_mark(0, "<")
    local finish = vim.api.nvim_buf_get_mark(0, ">")
    local selection = vim.api.nvim_buf_get_text(0, start[1] - 1, start[2], finish[1] - 1, finish[2] + 1, {})
    send_waystone_context(table.concat(selection, "\n"), start[1], start[2] + 1)
  end, { desc = "Waystone Send Selection" })
end

local function configure_waystone_mappings()
  if not vim.env.TMUX or vim.fn.executable("tmux") ~= 1 or vim.fn.executable("waystone") ~= 1 then
    return
  end

  vim.system({ "tmux", "display-message", "-p", "#{@waystone_worktree}" }, { text = true }, function(result)
    if result.code == 0 and result.stdout:match("%S") then
      vim.schedule(enable_waystone_mappings)
    end
  end)
end

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
      configure_waystone_mappings()
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
