vim.pack.add({ { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" } })

local neotree = require('neo-tree')

local top_set = {
	["main.c"] = true,
	["main.rs"] = true,
	["mod.rs"] = true,
	["lib.rs"] = true,
	["init.lua"] = true,
}

local function is_top(path)
	local name = path:match("([^/]+)$")
	return top_set[name] or false
end

neotree.setup({
	close_if_last_window = true,
	popup_border_style = '',
	hide_root_node = true,
	add_blank_line_at_top = false,
	default_component_configs = {
		name = { right_padding = 5, use_git_status_colors = false },
		indent = { with_expanders = true },
	},
	window = {
		auto_expand_width = true,
	},
	filesystem = {
		group_empty_dirs = true,
	},
	sort_function = function(a, b)
		if a.type ~= b.type then
			return a.type < b.type
		end

		local a_top = is_top(a.path)
		local b_top = is_top(b.path)

		if a_top ~= b_top then
			return a_top
		end

		return a.path < b.path
	end
})
