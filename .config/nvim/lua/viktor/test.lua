require("neotest").setup({
    adapters = {
        require("neotest-rust"),
        require('neotest-jest')({
            jestCommand = "npm test --",
            env = { CI = true },
            cwd = function(path)
                return vim.fn.getcwd()
            end,
        }),
    }
})

