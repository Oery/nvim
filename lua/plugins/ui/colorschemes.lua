-- installed colorschemes
local plugin = require("plugins.loader")

local shade = plugin.load({ src = "https://github.com/oery/shade.nvim" }, "shade")
if not shade then
	return
end

shade.setup({
	theme = "dark",
	transparent = true,
})

vim.cmd.colorscheme("shade")
