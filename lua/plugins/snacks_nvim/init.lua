-- Plugin collection

vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } })

local snacks = require("snacks")

snacks.setup({
	dim = require("plugins.snacks_nvim.dim"),
	indent = require("plugins.snacks_nvim.indent"),
	terminal = require("plugins.snacks_nvim.terminal"),
	dashboard = require("plugins.snacks_nvim.dashboard"),
	notifier = require("plugins.snacks_nvim.notifier"),
})
