vim.pack.add({ { src = "https://github.com/folke/lazydev.nvim" } })

require("lazydev").setup({
	integrations = {
		cmp = true,
		lspconfig = true,
	},
})
