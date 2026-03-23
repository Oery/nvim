local function get_makefile_target()
	local cwd = vim.loop.cwd()
	local makefile_path = cwd .. "/Makefile"

	-- Check if Makefile exists
	local stat = vim.loop.fs_stat(makefile_path)
	if not stat then
		return nil, "Makefile not found in cwd"
	end

	-- Open file
	local fd = io.open(makefile_path, "r")
	if not fd then
		return nil, "Failed to open Makefile"
	end

	for line in fd:lines() do
		-- Match NAME=... with optional spaces
		local name = line:match("^%s*NAME%s*=%s*(%S+)")
		if name then
			fd:close()
			return name
		end
	end

	fd:close()
	return nil, "NAME not found in Makefile"
end

return {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		console = "externalTerminal",
		program = function()
			local name, _ = get_makefile_target()
			if name then
				local result = vim.fn.system("make");
				if vim.v.shell_error ~= 0 then
					vim.notify("make failed: " .. result, vim.log.levels.ERROR)
					return ""
				end
				return name
			else
				return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
			end
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
}
