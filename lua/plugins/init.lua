local plugin = require("plugins.loader")

-- Everything that needs the plugins to be on disk.
local function configure()
	plugin.start()

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
	plugin.report()

	-- keymaps that need a plugin
	require("core.keymap").plugin_keymaps()
end

-- Plugins still have to be downloaded: Nvim does not draw the screen while
-- `init.lua` runs, so the install would look like a freeze. Let the editor come
-- up first and do the work on `VimEnter`, where the progress is visible.
if plugin.pending() > 0 then
	vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = configure })
else
	configure()
end
