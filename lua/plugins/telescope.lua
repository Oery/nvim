-- plugin to browse stuff

vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/cljoly/telescope-repo.nvim" },
})

local telescope = require("telescope")

telescope.setup({
	defaults = {
		prompt_prefix = '   ',
		selection_caret = ' ',
		entry_prefix = ' ',
		sorting_strategy = 'ascending',

		layout_config = {
			horizontal = {
				prompt_position = 'top',
				preview_width = 0.55,
			},
			width = 0.87,
			height = 0.80,
		},
	},
	extensions = {
		repo = {
			list = {
				tail_path = true,
				search_dirs = {
					'~/Documents/GitHub',
					'~/Documents/GitHub/oery',
					'~/Documents/Code',
					'~/Documents/42',
					'~/Downloads',
				}
			},
		},
	},
})

telescope.load_extension('repo')
