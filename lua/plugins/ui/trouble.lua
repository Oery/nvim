-- Plugin to display diagnostics

vim.pack.add({ { src = "https://github.com/folke/trouble.nvim" } })

local trouble = require('trouble')

trouble.setup({
	focus = true,
	win = { position = 'right', size = { width = 50 } },
})
