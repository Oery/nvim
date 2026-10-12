-- dependencies
require("plugins.ui.plenary")
require("plugins.ui.nui")

-- colorscheme (applies itself)
require("plugins.ui.colorschemes")

-- file icons
require("plugins.ui.nvim-web-devicons")

-- bufline
require("plugins.ui.cokeline")

-- mini plugin collection
require("plugins.mini.ai")
require("plugins.mini.move")
require("plugins.mini.pairs")
require("plugins.mini.surround")

-- file explorer
require("plugins.ui.neo-tree")

-- statusline
require("plugins.ui.lualine")

-- indentation
require("plugins.qol.guess-indent")

-- autoclose
require("plugins.qol.autoclose")

-- keybindings
require("plugins.ui.which-key")

-- anything that could not be loaded is reported once, here
require("plugins.loader").report()
