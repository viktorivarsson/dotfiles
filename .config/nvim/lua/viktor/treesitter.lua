local ok, configs = pcall(require, "nvim-treesitter.configs")

if not ok then
	return
end

configs.setup({
	auto_install = true,

	highlight = {
		-- `false` will disable the whole extension
		enable = true,
	},
})
