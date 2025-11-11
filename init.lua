-- Misc
vim.o.number = true
vim.o.numberwidth = 5
vim.o.wrap = false
vim.o.linebreak = true -- Don't break words
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.laststatus = 3 -- Global Status Line
vim.o.cmdheight = 0  -- Compact Status Line
vim.o.scrolloff = 10 -- Smooth Scroll
vim.o.winborder = 'rounded'
vim.opt.fillchars = { eob = " " }
vim.opt.splitkeep = "screen"

vim.lsp.inlay_hint.enable(true)
vim.o.clipboard = "unnamedplus"

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '',
			[vim.diagnostic.severity.WARN] = '',
			[vim.diagnostic.severity.INFO] = '',
			[vim.diagnostic.severity.HINT] = '󰌵',
		},
	}
})

-- Keybinds
vim.g.mapleader = " "
vim.keymap.set({ "n", "v", "s" }, ";", ":", { nowait = true })

vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Source file" })
vim.keymap.set("n", "<leader>e", ":Neotree reveal right<CR>", { desc = "File tree" })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "File picker" })
vim.keymap.set("n", "<leader>w", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>ld", ":Trouble diagnostics<CR>", { desc = "Diagnostics" })

vim.keymap.set("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true })
vim.keymap.set("n", "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true })

vim.keymap.set("n", "<leader>x", function()
	require("cokeline.buffers").get_current():delete()

	if #require("cokeline.buffers").get_visible() == 0 then
		require('snacks').dashboard.open()
	end
end, { desc = "Close current buffer" })

vim.keymap.set("n", "<leader>t", function()
	require("snacks").terminal()
end, { desc = "Open terminal" })

-- Packages
vim.pack.add({
	-- Dependencies
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },

	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/saecki/live-rename.nvim" },
	{ src = "https://github.com/Saecki/crates.nvim" },
	{ src = "https://github.com/saghen/blink.cmp",                          version = "v1.6.0" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim.git" },
	{ src = "https://github.com/j-hui/fidget.nvim" },

	-- Navigation
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/cljoly/telescope-repo.nvim" },
	{ src = "https://github.com/notjedi/nvim-rooter.lua" },
	{ src = "https://github.com/nanotee/zoxide.vim" },
	{ src = "https://github.com/m4xshen/autoclose.nvim" },
	{ src = "https://github.com/willothy/nvim-cokeline" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },

	-- Theming
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/NMAC427/guess-indent.nvim" },

	-- Colorschemes
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
	{ src = "https://github.com/datsfilipe/vesper.nvim" },
	{ src = "./renoir" },

	-- Tracking
	{ src = "https://github.com/vyfor/cord.nvim" },
	{ src = "https://github.com/wakatime/vim-wakatime" },
})

require('snacks').setup({
	indent = {
		enabled = true,
		animate = { enabled = false },
		scope = { only_current = true },
	},
	terminal = {
		win = { position = 'right', size = { width = 50 } },
		shell = 'fish',
	},
	dashboard = {
		width = 30,
		preset = {
			keys = {
				{ icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
				{ icon = ' ', key = 'p', desc = 'Find Project', action = ":Telescope repo" },
				{ icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
				{ icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{ icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
				{ icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
			},
			header = [[
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣋⣩⣤⣤⣤⣤⣤⣤⣤⣤⣍⣉⣉⣛⠛⠛⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣸⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⣁⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣦⣍⠙⢿⣿⣿⣿⣿⣿⣶⠉⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⡟⠋⠁⢠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠻⢿⣿⣿⣿⣿⡆⢹⣿⠁⠌⢹⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⣴⠟⣋⣉⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡈⣿⣿⣿⣿⡇⢸⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠟⠀⠀⠀⠀⠈⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠈⣿⣿⣿⣇⢸⣿⣿⣿⠁⠈⠉⠉⠙⠛⠻⠿⠿⠿⠟⠛⠛⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⡇⢹⣿⣿⣿⣿⣿⣿⡇⢹⣿⡟⢻⡀⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣷⠀⣠⡿⠟⣿⣿⣿⣿⣿⠇⠸⣿⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣿⠈⣿⡇⣤⠃⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣀⡀⠺⢿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡟⢰⡿⠁⣼⣿⣿⣿⣿⣿⢠⡀⠿⠿⠛⠛⣛⣃⣤⣤⣤⣴⣶⣶⣶⣤⣤⠀⣴⣿⠿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣷⣌⡙⢿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡇⡞⢠⠠⣿⣿⣿⠿⠟⠃⢸⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣏⣁⣀⣀⣀⣈⠀⣿⣿⠀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣄⠻⣿⣿⣿⣿⣿
⣿⡿⣿⣿⣇⠀⡿⠐⢋⡁⢠⠐⣿⠟⠋⢁⣠⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢀⣿⣿⠀⠃⠀⢀⣀⣀⣠⣤⣤⡄⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡇⢻⣿⣿⣿⣿
⣿⠁⠸⣿⣿⣾⠃⣼⣿⠃⣿⣧⠘⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⠀⠀⣠⣌⢹⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿
⣿⠀⣆⡙⠛⣡⣾⣿⡿⢀⣿⡏⢱⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⣸⣿⣿⠈⣿⣿⠟⠸⠿⠟⣋⣤⣤⣤⣤⣤⣤⣶⣶⣿⣿⣿⣿⣿⣿⡟⣸⣿⣿⣿⣿
⣿⣇⠹⢿⣿⡿⠛⣡⡇⢸⣿⣷⠈⠙⠋⠉⠉⠉⠛⠿⣿⣿⠿⢛⣉⣩⣭⣤⣤⣤⣴⣿⡿⠏⠐⠀⣡⣤⡙⢁⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣠⡌⢻⣿⣿⣿
⣿⣿⣷⠖⢀⣴⣿⣿⡇⢻⣿⣿⠀⠀⠀⠀⠀⠀⢀⣠⠌⠋⠰⠛⠉⠉⠀⠀⠀⠀⠀⠀⠀⠴⠿⠘⢿⡿⢃⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⣉⣤⠈⣿⡏⢸⣿⣿⣿
⣿⡟⢣⣼⣿⣿⣿⣿⣷⡈⠿⣿⡄⠀⠀⠀⣠⠖⠋⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠺⣿⡷⢰⣶⣿⣧⣶⣶⣦⣤⣤⣤⣤⣴⣶⣶⣶⣾⣿⠿⢁⠀⠛⣠⣿⣿⣿⣿
⣿⣇⣙⣉⣉⣉⣩⡙⢿⣿⣦⣤⣍⣀⠀⠘⠃⠀⠀⠀⠀⠀⠉⠻⣷⣦⡀⠀⠀⠀⢰⣿⣧⡄⢠⣤⣾⣿⣿⣿⣿⠟⠉⢉⣿⣿⣿⣿⣿⣿⡿⠛⣡⣴⣿⣴⣾⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠈⣿⣿⣿⣿⠿⠧⠀⣤⣤⡄⠀⠀⠀⠀⠀⠀⠹⠷⠀⠄⢤⠈⢛⣋⠀⠾⠿⠛⠿⠿⠏⣠⣾⢁⣚⣉⣉⣉⣉⣉⣉⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣤⣤⣤⣴⣶⣶⣶⣾⣿⣿⣷⣀⠀⠀⠀⠀⢀⠀⣤⣾⣷⡆⢶⣿⣿⣶⣶⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣿⣏⠸⢋⣩⣭⣥⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
]],
		},
		sections = {
			{ section = 'header' },
			{ pane = 2,          desc = "\n\n\n\n" },
			{ section = 'keys',  gap = 1,          pane = 2, width = 5 },
		},
	}
})


---@type neotree.Config
local neotree_config = {
	close_if_last_window = true,
	popup_border_style = '',
	hide_root_node = true,
	add_blank_line_at_top = false,
	default_component_configs = {
		name = { right_padding = 5, use_git_status_colors = false },
		indent = { with_expanders = true },
	},
	window = {
		-- width = 10,
		auto_expand_width = true,
	},
	filesystem = {
		group_empty_dirs = true,
	},
	-- Pin mod.rs files at the top
	sort_function = function(a, b)
		if a.type == b.type then
			if string.find(a.path, "main.rs") then
				return true
			elseif string.find(b.path, "main.rs") then
				return false
			end
			if string.find(a.path, "lib.rs") then
				return true
			elseif string.find(b.path, "lib.rs") then
				return false
			end
			if string.find(a.path, "mod.rs") then
				return true
			elseif string.find(b.path, "mod.rs") then
				return false
			end
			return a.path < b.path
		else
			return a.type < b.type
		end
	end,
}

require('neo-tree').setup(neotree_config)

require('guess-indent').setup({})
require("nvim-ts-autotag").setup()
require("crates").setup({})
require("autoclose").setup()
require("live-rename").setup()
require('lualine').setup { globalstatus = true }

require('cokeline').setup {
	show_if_buffers_are_at_least = 2,
	sidebar = false
}

require('todo-comments').setup()
require('which-key').setup { preset = 'helix' }

-- Diagnostics
require('trouble').setup({
	focus = true,
	win = { position = 'right', size = { width = 50 } },
})

require('tiny-inline-diagnostic').setup({
	preset = 'minimal',
	signs = { diag = " " },
})

require('telescope').setup({
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
					'~/Documents/Code',
					'~/Downloads',
				},
			},
		},
	},
})
require('telescope').load_extension('repo')

require('fidget').setup()

require('blink.cmp').setup {
	fuzzy = { implementation = 'prefer_rust_with_warning' }
}

require('conform').setup {
	formatters_by_ft = {},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
}


vim.lsp.enable('lua_ls')

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			diagnostics = { disable = { "missing-fields" } },
		},
	},
})


vim.lsp.enable("qmlls")
vim.lsp.enable("tsgo")
vim.lsp.enable("biome")
vim.lsp.enable('csharp_ls')

vim.lsp.enable('rust_analyzer')
vim.lsp.config('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
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

require('nvim-treesitter.configs').setup({
	auto_install = true,
	highlight = { enable = true },
})

-- Theming

require('renoir').setup {
	theme = 'dark',
	transparent = true,
}

vim.cmd(':colorscheme renoir')
