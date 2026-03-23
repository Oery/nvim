-- installed colorschemes

vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
	{ src = "https://github.com/datsfilipe/vesper.nvim" },
	{ src = "https://github.com/oery/shade.nvim" },
})

local shade = require('shade')

shade.setup {
	theme = 'dark',
	transparent = true,
}
