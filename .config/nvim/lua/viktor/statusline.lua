require("lualine").setup({
    options = {
        icons_enabled = true,
    },
    sections = {
        lualine_a = {'branch'},
        lualine_b = {'diff', 'diagnostics', 'searchcount'},
        lualine_c = {{ 'filename', file_status = true, path = 1 }},
        lualine_x = {'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {{ 'filename', file_status = true, path = 1 }},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'location'}
    },
})

