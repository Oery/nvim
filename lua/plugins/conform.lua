-- Plugin for autoformatting

vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } })

local conform = require("conform");

conform.setup({
	formatters = {
		c_formatter_42 = {
			command = "c_formatter_42",
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "c_formatter_42" },
		cpp = { "c_formatter_42" },
		javascript = { "biome" },
		javascriptreact = { "biome" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		python = { "ruff_format", "ruff_fix" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

vim.keymap.set("n", "<leader>lf",
	conform.format,
	{ desc = "Format buffer" }
)
