local function notify(msg, level)
	vim.notify(msg, level, { title = "orthodox.nvim" })
end

local function header_guard(name)
	return name:upper() .. "_HPP"
end

local function hpp_lines(name)
	local guard = header_guard(name)
	return {
		"#ifndef " .. guard,
		"# define " .. guard,
		"",
		"class " .. name,
		"{",
		"\tpublic:",
		"\t\t" .. name .. "();",
		"\t\t" .. name .. "(const " .. name .. " &other);",
		"\t\t" .. name .. " &operator=(const " .. name .. " &other);",
		"\t\t~" .. name .. "();",
		"\tprivate:",
		"};",
		"",
		"#endif",
	}
end

local function cpp_lines(name)
	return {
		'#include "' .. name .. '.hpp"',
		"",
		name .. "::" .. name .. "()",
		"{",
		"}",
		"",
		name .. "::" .. name .. "(const " .. name .. " &other)",
		"{",
		"}",
		"",
		name .. " &" .. name .. "::operator=(const " .. name .. " &other)",
		"{",
		"\treturn (*this);",
		"}",
		"",
		name .. "::~" .. name .. "()",
		"{",
		"}",
	}
end

local function format_files(paths)
	local unpack = unpack or table.unpack
	-- Fast path: clang-format is ~18ms vs ~190ms per bufadd+load + LSP.
	-- Prefer it for cpp/hpp when available (always true per `which clang-format`).
	if vim.fn.executable("clang-format") == 1 then
		local out = vim.fn.system({ "clang-format", "-i", unpack(paths) })
		if vim.v.shell_error ~= 0 then
			notify(("clang-format failed:\n%s"):format(out), vim.log.levels.WARN)
		end
		return
	end

	-- Fallback 1: conform.nvim (respects formatters_by_ft + lsp fallback)
	local has_conform, conform = pcall(require, "conform")
	if has_conform then
		for _, path in ipairs(paths) do
			local bufnr = vim.fn.bufadd(path)
			vim.fn.bufload(bufnr)
			if vim.bo[bufnr].filetype == "" then
				vim.bo[bufnr].filetype = "cpp"
			end
			pcall(conform.format, { bufnr = bufnr, async = false, lsp_format = "fallback" })
			pcall(vim.api.nvim_buf_call, bufnr, function()
				vim.cmd("silent noautocmd write")
			end)
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
		return
	end

	-- Fallback 2: LSP (attach global formatter clients to temp buffers)
	for _, path in ipairs(paths) do
		local bufnr = vim.fn.bufadd(path)
		vim.fn.bufload(bufnr)
		if vim.bo[bufnr].filetype == "" then
			vim.bo[bufnr].filetype = "cpp"
		end
		for _, client in ipairs(vim.lsp.get_clients()) do
			if client.supports_method("textDocument/formatting") then
				pcall(vim.lsp.buf_attach_client, bufnr, client.id)
			end
		end
		local has_formatter = false
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client.supports_method("textDocument/formatting") then
				has_formatter = true
				break
			end
		end
		if has_formatter then
			pcall(vim.api.nvim_buf_call, bufnr, function()
				pcall(vim.lsp.buf.format, { async = false, bufnr = bufnr })
			end)
			pcall(vim.api.nvim_buf_call, bufnr, function()
				vim.cmd("silent noautocmd write")
			end)
		end
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

local function generate(class_name)
	if type(class_name) ~= "string" or not class_name:match("^[A-Za-z_][A-Za-z0-9_]*$") then
		notify(("Invalid class name: %s"):format(tostring(class_name)), vim.log.levels.ERROR)
		return
	end

	local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not dir or dir == "" then
		dir = vim.uv.cwd()
	end

	local hpp_path = vim.fs.joinpath(dir, class_name .. ".hpp")
	local cpp_path = vim.fs.joinpath(dir, class_name .. ".cpp")

	for _, path in ipairs({ hpp_path, cpp_path }) do
		if vim.uv.fs_stat(path) then
			notify(("Aborting: %s already exists"):format(vim.fn.fnamemodify(path, ":~:.")), vim.log.levels.ERROR)
			return
		end
	end

	if vim.fn.writefile(hpp_lines(class_name), hpp_path) ~= 0 then
		notify(("Failed to write %s"):format(hpp_path), vim.log.levels.ERROR)
		return
	end
	if vim.fn.writefile(cpp_lines(class_name), cpp_path) ~= 0 then
		notify(("Failed to write %s"):format(cpp_path), vim.log.levels.ERROR)
		pcall(vim.uv.fs_unlink, hpp_path) -- rollback half-state
		return
	end

	-- Async formatting: write is ~5ms, clang-format ~15-100ms, edit ~300-1100ms (clangd+treesitter).
	-- Run formatter off main loop so :Orthodox returns instantly.
	local function open_header()
		-- Use scheduled edit to avoid blocking the caller; still triggers LSP/treesitter but after return
		vim.schedule(function()
			vim.cmd.edit(vim.fn.fnameescape(hpp_path))
		end)
	end

	if vim.fn.executable("clang-format") == 1 then
		local unpack = unpack or table.unpack
		vim.system({ "clang-format", "-i", hpp_path, cpp_path }, { text = true }, function(obj)
			vim.schedule(function()
				if obj.code ~= 0 then
					notify(("clang-format failed:\n%s"):format(obj.stderr or ""), vim.log.levels.WARN)
				end
				open_header()
			end)
		end)
		return
	end

	-- Fallback (no clang-format): use conform/LSP sync path then open
	format_files({ hpp_path, cpp_path })
	open_header()
end

vim.api.nvim_create_user_command("Orthodox", function(opts)
	generate(opts.args)
end, {
	nargs = 1,
	desc = "Generate an Orthodox Canonical Form C++ class (.hpp/.cpp) and open the header",
})

return { generate = generate }
