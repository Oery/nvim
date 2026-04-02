-- 42 norm linter

vim.pack.add({ { src = "https://github.com/Oery/42norm.nvim" } })

local norm = require("42norm")

norm.setup({
	format_on_save = false,
	header_on_save = true,
	lint_on_change = false,
	ignore = {},
})
