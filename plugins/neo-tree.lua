require("neo-tree").setup {
	close_if_last_window = true,
	popup_border_style = "",

	default_component_configs = {
		name = { right_padding = 5, use_git_status_colors = false },
		indent = { with_expanders = true },
	},

	window = {
		width = 10,
		auto_expand_width = true,
	},

	filesystem = {
		group_empty_dirs = true,
	},

	-- Pin mod.rs/main.rs/lib.rs files at the top
	sort_function = function(a, b)
		if a.type == b.type then
			if string.find(a.path, "main.rs") then
				return true
			elseif string.find(b.path, "main.rs") then
				return false
			end
			if string.find(a.path, "lib.rs") then
				return true
			elseif string.find(b.path, "lib.rs") then
				return false
			end
			if string.find(a.path, "mod.rs") then
				return true
			elseif string.find(b.path, "mod.rs") then
				return false
			end
			return a.path < b.path
		else
			return a.type < b.type
		end
	end,
}
