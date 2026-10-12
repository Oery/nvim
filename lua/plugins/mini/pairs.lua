local plugin = require("plugins.loader")

local pairs = plugin.load({ src = "https://github.com/nvim-mini/mini.nvim" }, "mini.pairs")
if not pairs then
	return
end

pairs.setup()
