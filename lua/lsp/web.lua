local capabilities = require("blink.cmp").get_lsp_capabilities()

local function ts_ls_on_attach(client, bufnr)
	if client.supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
end

vim.lsp.config("ts_ls", {
	on_attach = ts_ls_on_attach,
	settings = {
		preferences = {
			importModuleSpecifiers = "relative",
		},
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = "literals",
				includeInlayParameterNameHintsForArguments = false,
				includeInlayParameterNameHintsForLiterals = true,
				includeInlayParameterNameHintsForObjects = false,
				includeInlayParameterNameHintsForVariables = false,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayParameterNameHints = "literals",
				includeInlayParameterNameHintsForArguments = false,
				includeInlayParameterNameHintsForLiterals = true,
				includeInlayParameterNameHintsForObjects = false,
				includeInlayParameterNameHintsForVariables = false,
			},
		},
	},
})

vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")
vim.lsp.enable("tailwindcss")

vim.lsp.config("cssls", {
	init_options = {
		capabilities = capabilities,
	},
})

vim.lsp.config("tailwindcss", {
	init_options = {
		tailwindCSS = {
			classAttributes = {
				"class",
				"className",
				"ngClass",
			},
			includeMachineTwinInterface = true,
			experimental = {
				supportHtmlElements = true,
			},
		},
	},
})
