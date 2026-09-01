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

local function node_with_type(node, wanted_type)
	while node do
		if node:type() == wanted_type then
			return node
		end
		node = node:parent()
	end
end

local function open_source(path)
	-- A new declaration in the header is commonly unsaved. Hide that buffer instead
	-- of failing with E37 when jumping to its implementation.
	vim.cmd("hide edit " .. vim.fn.fnameescape(path))
end

local function class_method_at_cursor()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local parser_ok, parser = pcall(vim.treesitter.get_parser, 0)
	if parser_ok then
		parser:parse()
	end
	local ok, node = pcall(vim.treesitter.get_node, { pos = { cursor[1] - 1, cursor[2] } })
	if not ok or not node then
		return nil, "Tree-sitter could not find a declaration at the cursor"
	end

	local declaration = node_with_type(node, "field_declaration")
	local class = node_with_type(node, "class_specifier")
	if not declaration or not class then
		return nil, "Place the cursor on a method declaration inside a class"
	end

	local class_name_node = class:field("name")[1]
	if not class_name_node then
		return nil, "Could not determine the enclosing class name"
	end

	local text = vim.treesitter.get_node_text(declaration, 0)
	text = text:gsub("//[^\n]*", ""):gsub("/%*.-%*/", " "):gsub("%s+", " ")
	text = vim.trim(text)
	if text:find("{", 1, true)
		or text:match("=%s*default%s*;")
		or text:match("=%s*delete%s*;")
		or text:match("=%s*0%s*;") then
		return nil, "That declaration cannot be generated as an out-of-class definition"
	end

	-- This intentionally covers normal methods, constructors, and destructors.  The
	-- declaration is kept mostly intact so parameter names, namespaces, and qualifiers
	-- do not have to be reconstructed by hand.
	local prefix, method, params, suffix = text:match("^(.-)([~%a_][%w_~]*%s*)(%b())(.*)$")
	if not method then
		return nil, "Could not parse this method declaration"
	end

	method = vim.trim(method)
	prefix = vim.trim(prefix)
	suffix = suffix:gsub(";%s*$", "")
	suffix = suffix:gsub("%f[%a]override%f[^%a]", "")
	suffix = suffix:gsub("%f[%a]final%f[^%a]", "")
	suffix = vim.trim(suffix)
	-- These specifiers belong only on the declaration. constexpr is deliberately
	-- retained because its definition must also be constexpr.
	prefix = prefix:gsub("%f[%a]virtual%f[^%a]", "")
	prefix = prefix:gsub("%f[%a]static%f[^%a]", "")
	prefix = prefix:gsub("%f[%a]inline%f[^%a]", "")
	prefix = prefix:gsub("%f[%a]explicit%f[^%a]", "")
	prefix = vim.trim(prefix)

	local signature = table.concat(vim.tbl_filter(function(part)
		return part ~= ""
	end, { prefix, vim.treesitter.get_node_text(class_name_node, 0) .. "::" .. method .. params, suffix }), " ")

	return {
		class_name = vim.treesitter.get_node_text(class_name_node, 0),
		method = method,
		signature = signature,
	}
end

local function implement_method()
	if vim.bo.filetype ~= "cpp" or vim.fn.expand("%:e") ~= "hpp" then
		notify("Implement Method is available from .hpp C++ headers", vim.log.levels.WARN)
		return
	end

	local method, err = class_method_at_cursor()
	if not method then
		notify(err, vim.log.levels.WARN)
		return
	end

	local header = vim.api.nvim_buf_get_name(0)
	local source = vim.fn.expand("%:r") .. ".cpp"
	if vim.uv.fs_stat(source) then
		local source_lines = vim.fn.readfile(source)
		local loaded = vim.fn.bufnr(source, false)
		if loaded ~= -1 and vim.api.nvim_buf_is_loaded(loaded) then
			source_lines = vim.api.nvim_buf_get_lines(loaded, 0, -1, false)
		end
		local definition_line
		for line_number, line in ipairs(source_lines) do
			if line:find(method.class_name .. "::" .. method.method .. "%s*%(") then
				definition_line = line_number
				break
			end
		end
		if definition_line then
			open_source(source)
			vim.api.nvim_win_set_cursor(0, { definition_line, 0 })
			return
		end
	else
		local include = vim.fn.fnamemodify(header, ":t")
		vim.fn.writefile({ '#include "' .. include .. '"', "" }, source)
	end

	open_source(source)
	local bufnr = vim.api.nvim_get_current_buf()
	local last_line = vim.api.nvim_buf_line_count(bufnr)
	local needs_separator = vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, false)[1] ~= ""
	local lines = needs_separator and { "", method.signature, "{", "\t", "}" }
		or { method.signature, "{", "\t", "}" }
	vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
	local body_line = vim.api.nvim_buf_line_count(bufnr) - 1
	vim.api.nvim_win_set_cursor(0, { body_line, 1 })
	-- Normal mode clamps the cursor to column 0 on a whitespace-only line.
	-- startinsert! enters at end-of-line, preserving the skeleton's initial tab.
	vim.cmd("startinsert!")
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

vim.api.nvim_create_user_command("ImplementCppMethod", implement_method, {
	desc = "Create the C++ implementation for the class method at the cursor",
})

return { generate = generate, implement_method = implement_method }
