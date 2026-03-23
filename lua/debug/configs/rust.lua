local function get_cargo_binary()
	local cargo_toml_path = vim.loop.cwd() .. "/Cargo.toml"
	local stat = vim.loop.fs_stat(cargo_toml_path)
	if not stat then
		return nil, "Cargo.toml not found in cwd"
	end

	local fd = io.open(cargo_toml_path, "r")
	if not fd then
		return nil, "Failed to open Cargo.toml"
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

	if not name then
		return nil, "name not found in Cargo.toml"
	end

	local debug = vim.loop.fs_stat("target/debug/" .. name)
	if debug then
		return "target/debug/" .. name
	end

	return nil, "Binary not found in target/debug"
end


return {
	{
		name = "Launch Cargo binary",
		type = "codelldb",
		request = "launch",
		console = "externalTerminal",
		program = function()
			local bin, _ = get_cargo_binary()
			if bin then
				local result = vim.fn.system("cargo build");
				if vim.v.shell_error ~= 0 then
					vim.notify("cargo build failed: " .. result, vim.log.levels.ERROR)
					return ""
				end
				return bin
			end
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		sourceLanguages = { "rust" },
	},
}
