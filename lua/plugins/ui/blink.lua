vim.pack.add({ { src = "https://github.com/saghen/blink.cmp", version = "v1.6.0" } })

local blink = require("blink.cmp")

blink.setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	sources = {
		default = { "lazydev", "lsp", "path" },
		transform_items = function(_, items)
			return vim.tbl_filter(function(item)
				return item.kind ~= vim.lsp.protocol.CompletionItemKind.Snippet
			end, items)
		end,
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
		},
	},
	completion = {
		menu = { auto_show = true },
		trigger = {
			show_on_trigger_character = true,
			show_on_keyword = false,
		},
	},
})
