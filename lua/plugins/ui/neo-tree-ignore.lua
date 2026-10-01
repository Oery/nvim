local M = {}
local installed = false

function M.setup()
	if installed then
		return
	end
	installed = true

	local glob = require("neo-tree.sources.filesystem.lib.lua-glob")
	local gitignore = glob.gitignore

	glob.gitignore = function(...)
		local parser = gitignore(...)
		local check = parser.check
		local check_slice = parser.checkPatternSlice

		parser.checkPatternSlice = function(self, paths, path_index, pattern, pattern_index)
			-- Match this path exactly; parent directories are checked separately below.
			if pattern.symbols[pattern_index] == nil and path_index ~= #paths then
				return false
			end
			return check_slice(self, paths, path_index, pattern, pattern_index)
		end

		parser.check = function(self, path)
			if not self.options.asGitIgnore then
				return check(self, path)
			end

			local prefix = {}
			local status
			for _, part in ipairs(self:toPaths(path)) do
				prefix[#prefix + 1] = part
				status = self:status(prefix)
				if status == glob.Statuses.ACCEPTED then
					return true
				end
				-- An included parent (e.g. !*/) must not skip its children's rules.
			end

			if status == glob.Statuses.REFUSED then
				return false
			end
		end

		return parser
	end
end

return M
