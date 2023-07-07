return {
	"jcdickinson/wpm.nvim",
	event = "VeryLazy",
	config = function()
		require("wpm").setup({})
	end,
}
