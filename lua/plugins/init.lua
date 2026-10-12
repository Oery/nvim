-- The plugins live in `pack/lite/start` (see `:h packages`), so Neovim puts
-- them on 'runtimepath' by itself: there is no plugin manager, no lockfile and
-- no download involved.
--
-- colorscheme
require("plugins.ui.colorschemes")

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

-- keybindings
require("plugins.ui.which-key")
