local plugin = require("plugins.loader")

local move = plugin.load({ src = "https://github.com/nvim-mini/mini.nvim" }, "mini.move")
if not move then
	return
end

move.setup({
	mappings = {
		-- yes, i use arrow keys
		left = '<M-left>',
		right = '<M-right>',
		down = '<M-down>',
		up = '<M-up>',

		line_left = '<M-left>',
		line_right = '<M-right>',
		line_down = '<M-down>',
		line_up = '<M-up>',
	},
})
