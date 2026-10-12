-- installed colorschemes
vim.pack.add({
	{ src = "https://github.com/oery/shade.nvim" },
}, { confirm = false })

local shade = require("shade")

shade.setup({
	theme = "dark",
	transparent = true,
})
