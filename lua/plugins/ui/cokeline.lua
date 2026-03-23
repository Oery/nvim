-- vscode like tab system
vim.pack.add({ { src = "https://github.com/willothy/nvim-cokeline" } })

local cokeline = require("cokeline")

cokeline.setup({
	show_if_buffers_are_at_least = 2,
	sidebar = false
})
