local function get_module_name()
	local pyproject_path = vim.loop.cwd() .. "/pyproject.toml"
	local stat = vim.loop.fs_stat(pyproject_path)
	if not stat then
		return nil
	end

	local fd = io.open(pyproject_path, "r")
	if not fd then
		return nil
	end

	local name = nil
	for line in fd:lines() do
		local m = line:match("^%s*name%s*=%s*[\"']?([^\"'%s]+)[\"']?")
		if m then
			name = m
			break
		end
	end
	fd:close()

	return name
end

return {
	{
		name = "Debug Python: Module",
		type = "debugpy",
		request = "launch",
		module = function()
			local name = get_module_name()
			if name then
				return name
			end
			return vim.fn.input("Module name: ", "", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		console = "integratedTerminal",
	},
	{
		name = "Debug Python: Current File",
		type = "debugpy",
		request = "launch",
		module = "${fileBasename}",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		console = "integratedTerminal",
	},
	{
		name = "Debug Python: pytest",
		type = "debugpy",
		request = "launch",
		module = "pytest",
		args = {
			"--",
			"-s",
		},
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		console = "integratedTerminal",
	},
}
