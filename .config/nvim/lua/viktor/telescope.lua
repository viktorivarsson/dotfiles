require('telescope').setup{
    defaults = {
        file_ignore_patterns = { "node_modules", "yarn.lock" },
        path_display = {
            truncate = 3,
        },
    }
}
