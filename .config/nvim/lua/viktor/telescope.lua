local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local telescope_config = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!.git/*")

require("telescope").setup{
    defaults = {
        file_ignore_patterns = { "node_modules", "yarn.lock", ".git" },
        vimgrep_arguments = vimgrep_arguments,
        path_display = {
            truncate = 3,
        },
    },
    pickers = {
        find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
    }
}

require("telescope").load_extension("git_worktree")

local m = {}

m.buffers = function(opts)
    opts = opts or {}

    opts.attach_mappings = function(prompt_bufnr, map)
        local delete_buf = function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.api.nvim_buf_delete(selection.bufnr, { force = true })
        end
        map("i", "<c-d>", delete_buf)
        return true
    end

    require("telescope.builtin").buffers(require("telescope.themes").get_ivy(opts))
end

m.find_files = function(opts)
    require("telescope.builtin").find_files(require("telescope.themes").get_ivy(opts))
end

m.live_grep = function(opts)
    require("telescope.builtin").live_grep(require("telescope.themes").get_ivy(opts))
end

m.help_tags = function(opts)
    require("telescope.builtin").help_tags(require("telescope.themes").get_ivy(opts))
end

m.lsp_references = function(opts)
    require("telescope.builtin").lsp_references(require("telescope.themes").get_ivy(opts))
end

m.treesitter = function(opts)
    require("telescope.builtin").treesitter(require("telescope.themes").get_ivy(opts))
end


return m

