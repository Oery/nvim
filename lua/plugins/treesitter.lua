vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

local treesitter = require("nvim-treesitter")
local ts_objects = require("nvim-treesitter-textobjects")

treesitter.setup({
	auto_install = true,

	text_objects = {
		select = {
			enable = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["as"] = "@locals.outer",
				["is"] = "@locals.inner",
			},
		},
	},
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

vim.g.no_plugin_maps = true

ts_objects.setup {
	select = {
		lookahead = true,
		selection_modes = {
			['@parameter.outer'] = 'v', -- charwise
			['@function.outer'] = 'V', -- linewise
		},
		include_surrounding_whitespace = false,
	},
}
