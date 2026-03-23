-- dependencies
require("plugins.ui.plenary")
require("plugins.ui.nui")

require("plugins.lazydev")

require("plugins.treesitter")
require("plugins.telescope")

-- colorschemes
require("plugins.ui.colorschemes")
vim.cmd.colorscheme('shade')

-- lsp completion
require("plugins.ui.blink")

-- autoformatter
require("plugins.conform")

-- diagnostics panel
require("plugins.ui.trouble")

-- bufline
require("plugins.ui.cokeline")

-- snacks plugin collection
require("plugins.snacks_nvim.init")

-- mini plugin collection
require("plugins.mini.move")
require("plugins.mini.pairs")

-- lsp loading status
require("plugins.ui.fidget")

-- file explorer
require("plugins.ui.neo-tree")

-- statusline
require("plugins.ui.lualine")
require("plugins.ui.nvim-web-devicons")

-- indentation
require("plugins.qol.guess-indent")

-- auto tags
require("plugins.qol.nvim-ts-autotag")

-- tabout
require("plugins.qol.tabout")

-- keybindings
require("plugins.ui.which-key")

-- todo comments
require("plugins.ui.todo-comments")

-- inline diagnostics
require("plugins.ui.tiny-inline-diagnostic")

-- markdown rendering
require("plugins.ui.render-markdown")

-- live rename
require("plugins.ui.live-rename")

-- rust crates
require("plugins.rust.crates")

-- autoclose
require("plugins.qol.autoclose")

-- discord rich presence
require("plugins.tracking.cord")
require("plugins.tracking.wakatime")

if vim.env.name == "42-env" then
	-- 42 norm
	require("plugins.42norm")

	-- cloak sensitive strings
	require("plugins.ui.cloak")
end
