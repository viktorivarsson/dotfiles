require("impatient")

require("viktor")

function _G.reload_nvim_conf()
	for name, _ in pairs(package.loaded) do
		if name:match("^viktor") or name:match("^plugins") then
			package.loaded[name] = nil
		end
	end

	dofile(vim.env.MYVIMRC)
	vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end
