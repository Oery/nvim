local which_key = require("plugins.loader").load({ src = "https://github.com/folke/which-key.nvim" }, "which-key")
if not which_key then
	return
end

which_key.setup({ preset = 'helix' })
