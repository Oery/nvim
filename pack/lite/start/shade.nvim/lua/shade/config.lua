local config = {
	defaults = {
		theme = "dark",
		transparent = false,
		italics = {
			comments = true,
			keywords = true,
			functions = true,
			strings = false,
			variables = false,
			bufferline = false,
		},
		overrides = {},
	},
}

setmetatable(config, { __index = config.defaults })

return config
