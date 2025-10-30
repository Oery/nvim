vim.lsp.enable("rust_analyzer")

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				chainingHints = { enable = false },
				bindingModeHints = { enable = false },
				typeHints = { enable = false },
				closingBraceHints = { enable = false },
				discriminantHints = { enable = true },
			},
		},
	},
})
