local lualine = require("plugins.loader").load({ src = "https://github.com/nvim-lualine/lualine.nvim" }, "lualine")
if not lualine then
	return
end

lualine.setup({ globalstatus = true })
