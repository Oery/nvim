local guess_indent = require("plugins.loader").load({ src = "https://github.com/NMAC427/guess-indent.nvim" }, "guess-indent")
if not guess_indent then
	return
end

guess_indent.setup()
