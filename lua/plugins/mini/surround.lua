local plugin = require("plugins.loader")

local surround = plugin.load({ src = "https://github.com/nvim-mini/mini.nvim" }, "mini.surround")
if not surround then
	return
end

surround.setup()
