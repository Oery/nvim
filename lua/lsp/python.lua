vim.lsp.enable("pylsp")

vim.lsp.config("pylsp", {
	settings = {
		pylsp = {
			plugins = {
				ruff = {
					enabled = true,
					select = { "E", "F", "I", "N", "W" },
				},
				ruff_fixer = {
					enabled = true,
				},
			},
		},
	},
})
