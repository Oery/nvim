local plugin = require("plugins.loader")

local ai = plugin.load({ src = "https://github.com/nvim-mini/mini.nvim" }, "mini.ai")
if not ai then
	return
end

ai.setup()
