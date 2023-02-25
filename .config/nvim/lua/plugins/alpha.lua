return {
	{
		"goolord/alpha-nvim",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		config = function()
			local startify_config = require("alpha.themes.startify")

			-- https://patorjk.com/software/taag/#p=display&f=Big%20Money-nw&t=Type%20Something%20
			local header = {
				type = "text",
				val = {
					[[$$\     $$\  $$$$$$\  $$\   $$\       $$$$$$$$\  $$$$$$\   $$$$$$\  $$\       $$\ ]],
					[[\$$\   $$  |$$  __$$\ $$ |  $$ |      $$  _____|$$  __$$\ $$  __$$\ $$ |      $$ |]],
					[[ \$$\ $$  / $$ /  $$ |$$ |  $$ |      $$ |      $$ /  $$ |$$ /  $$ |$$ |      $$ |]],
					[[  \$$$$  /  $$ |  $$ |$$ |  $$ |      $$$$$\    $$ |  $$ |$$ |  $$ |$$ |      $$ |]],
					[[   \$$  /   $$ |  $$ |$$ |  $$ |      $$  __|   $$ |  $$ |$$ |  $$ |$$ |      \__|]],
					[[    $$ |    $$ |  $$ |$$ |  $$ |      $$ |      $$ |  $$ |$$ |  $$ |$$ |          ]],
					[[    $$ |     $$$$$$  |\$$$$$$  |      $$ |       $$$$$$  | $$$$$$  |$$$$$$$$\ $$\ ]],
					[[    \__|     \______/  \______/       \__|       \______/  \______/ \________|\__|]],
				},
				opts = {
					hl = "Type",
					shrink_margin = false,
				},
			}

			require("alpha").setup({
				layout = {
					{ type = "padding", val = 1 },
					header,
					{ type = "padding", val = 2 },
					startify_config.section.mru_cwd,
				},
				opts = {
					margin = 3,
					redraw_on_resize = false,
					setup = function()
						vim.cmd([[
            autocmd alpha_temp DirChanged * lua require('alpha').redraw()
            ]])
					end,
				},
			})
		end,
	},
}
