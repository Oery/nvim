-- vscode like tab system
local plugin = require("plugins.loader")

local cokeline = plugin.load({ src = "https://github.com/willothy/nvim-cokeline" }, "cokeline")
if not cokeline then
	return
end

cokeline.setup({
	show_if_buffers_are_at_least = 2,
	sidebar = false
})
