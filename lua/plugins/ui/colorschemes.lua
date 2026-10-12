-- installed colorschemes
local shade = require("shade")

shade.setup({
	theme = "dark",
	transparent = true,
})

vim.cmd.colorscheme("shade")
