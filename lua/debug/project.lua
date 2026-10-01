local M = {}
local dap = require("dap")
local uv = vim.uv
local busy = false

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.ERROR, { title = "Project debugging" })
end

-- Tokenize executable and argv without invoking a shell. Preserve quoted and
-- escaped spaces and empty arguments, but reject unquoted shell operators.
function M.parse_command(command)
	if command:find("[%z\r\n]") then
		return nil, "The debug command must be a single line"
	end
	local argv, token = {}, {}
	local quote, started = nil, false
	local i = 1
	while i <= #command do
		local char = command:sub(i, i)
		if char == "\\" and quote ~= "'" then
			local next_char = command:sub(i + 1, i + 1)
			if next_char == "" then
				return nil, "Trailing escape in debug command"
			end
			if quote == '"' and not next_char:match('["\\$`]') then
				token[#token + 1] = char
			else
				i = i + 1
				token[#token + 1] = next_char
			end
			started = true
		elseif quote then
			if char == quote then
				quote = nil
			else
				token[#token + 1] = char
			end
		elseif char == "'" or char == '"' then
			quote, started = char, true
		elseif char:match("%s") then
			if started then
				argv[#argv + 1] = table.concat(token)
				token, started = {}, false
			end
		elseif char:match("[|&;<>()`]") then
			return nil, "Use an executable and arguments; shell operators are not supported"
		else
			token[#token + 1], started = char, true
		end
		i = i + 1
	end
	if quote then
		return nil, "Unclosed quote in debug command"
	end
	if started then
		argv[#argv + 1] = table.concat(token)
	end
	if not argv[1] or argv[1] == "" then
		return nil, "Enter an executable and its arguments"
	end
	if argv[1]:match("^[%a_][%w_]*=") then
		return nil, "Environment assignments are not supported in debug commands"
	end
	return argv
end

function M.project_root()
	local buffer = vim.api.nvim_buf_get_name(0)
	local start
	if vim.bo.buftype == "" and buffer ~= "" then
		start = vim.fs.dirname(buffer)
	else
		local session = dap.session()
		start = session and session.config.cwd or vim.fn.getcwd()
	end
	local root = vim.fs.root(start, ".git") or vim.fs.root(start, "Makefile") or vim.fn.getcwd()
	return uv.fs_realpath(root) or vim.fs.normalize(root)
end

local function state_path()
	return vim.fn.stdpath("state") .. "/debug-commands.json"
end

local function read_commands()
	local path = state_path()
	if not uv.fs_stat(path) then
		return {}
	end
	local ok, commands = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	end)
	if not ok or type(commands) ~= "table" or vim.islist(commands) then
		return nil, "Cannot read saved debug commands: " .. path
	end
	for root, command in pairs(commands) do
		if type(root) ~= "string" or type(command) ~= "string" then
			return nil, "Invalid saved debug commands: " .. path
		end
	end
	return commands
end

local function save_command(root, command)
	-- Read again so another Neovim instance's projects are not overwritten.
	local commands, err = read_commands()
	if not commands then
		return nil, err
	end
	commands[root] = command
	local path = state_path()
	local temporary
	local ok, result = pcall(function()
		vim.fn.mkdir(vim.fs.dirname(path), "p")
		local fd
		fd, temporary = uv.fs_mkstemp(path .. ".XXXXXX")
		assert(fd, temporary)
		local data = vim.json.encode(commands) .. "\n"
		local written, write_err = uv.fs_write(fd, data, 0)
		uv.fs_close(fd)
		assert(written == #data, write_err or "Incomplete state write")
		local renamed, rename_err = uv.fs_rename(temporary, path)
		assert(renamed, rename_err)
	end)
	if not ok then
		if temporary then
			uv.fs_unlink(temporary)
		end
		return nil, "Cannot save debug command: " .. tostring(result)
	end
	return true
end

local function initial_command(root)
	local makefile = io.open(root .. "/Makefile", "r")
	if not makefile then
		return "./"
	end
	for line in makefile:lines() do
		local name = line:match("^%s*NAME%s*:?=%s*([^%s#]+)")
		if name and not name:find("$", 1, true) then
			makefile:close()
			return "./" .. name
		end
	end
	makefile:close()
	return "./"
end

local function executable_path(root, executable)
	if executable:sub(1, 2) == "~/" then
		executable = vim.fn.expand("~") .. executable:sub(2)
	end
	local path
	if executable:find("/", 1, true) then
		path = executable:sub(1, 1) == "/" and executable or root .. "/" .. executable
	else
		path = vim.fn.exepath(executable)
		if path ~= "" and path:sub(1, 1) ~= "/" then
			path = vim.fn.fnamemodify(path, ":p")
		end
	end
	local stat = path and uv.fs_stat(path)
	if not stat or stat.type ~= "file" or vim.fn.executable(path) ~= 1 then
		return nil, "Executable not found or not executable: " .. executable
	end
	return uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function prepare(root, force_prompt, done)
	if busy then
		notify("A project debug launch is already being prepared", vim.log.levels.WARN)
		done(nil)
		return
	end
	busy = true
	local function finish(config, err)
		busy = false
		if err then
			notify(err)
		end
		done(config)
	end
	local commands, err = read_commands()
	if not commands then
		finish(nil, err)
		return
	end
	local saved = commands[root]
	local function use_command(command)
		if command == nil then
			finish(nil)
			return
		end
		local argv, parse_err = M.parse_command(command)
		if not argv then
			finish(nil, parse_err)
			return
		end
		local function launch_config()
			local program, program_err = executable_path(root, argv[1])
			if not program then
				finish(nil, program_err)
				return
			end
			if command ~= saved then
				local stored, store_err = save_command(root, command)
				if not stored then
					finish(nil, store_err)
					return
				end
			end
			table.remove(argv, 1)
			finish({
				name = "Launch project command",
				type = "codelldb",
				request = "launch",
				program = program,
				args = argv,
				cwd = root,
				terminal = "integrated",
				stopOnEntry = false,
			})
		end
		if not uv.fs_stat(root .. "/Makefile") then
			launch_config()
			return
		end
		notify("Building " .. root .. " with make…", vim.log.levels.INFO)
		local ok, build_err = pcall(
			vim.system,
			{ "make" },
			{ cwd = root, text = true },
			vim.schedule_wrap(function(result)
				if result.code ~= 0 then
					finish(
						nil,
						"make failed (exit " .. result.code .. "):\n" .. (result.stdout or "") .. (result.stderr or "")
					)
				else
					launch_config()
				end
			end)
		)
		if not ok then
			finish(nil, "Cannot run make: " .. tostring(build_err))
		end
	end
	if force_prompt or not saved then
		vim.ui.input(
			{ prompt = "Debug command: ", default = saved or initial_command(root), completion = "file" },
			use_command
		)
	else
		use_command(saved)
	end
end

-- nvim-dap evaluates callable configurations inside a coroutine. Bridge its
-- preparation to the same asynchronous prompt/build path used by DebugRunNew.
function M.configuration(root)
	return setmetatable({ name = "Launch project command", type = "codelldb", request = "launch" }, {
		__call = function()
			local thread = coroutine.running()
			prepare(
				root or M.project_root(),
				false,
				vim.schedule_wrap(function(config)
					local ok, err = coroutine.resume(thread, config or { program = dap.ABORT })
					if not ok then
						notify(tostring(err))
					end
				end)
			)
			return coroutine.yield()
		end,
	})
end

function M.run()
	if dap.session() then
		dap.continue()
	else
		dap.run(M.configuration(M.project_root()))
	end
end

function M.run_new()
	prepare(M.project_root(), true, function(config)
		if not config then
			return
		end
		local function launch()
			dap.run(config, { new = true })
		end
		if dap.session() then
			dap.terminate({ on_done = vim.schedule_wrap(launch) })
		else
			launch()
		end
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("DebugRun", M.run, { desc = "Run saved C/C++ project command or continue" })
	vim.api.nvim_create_user_command(
		"DebugRunNew",
		M.run_new,
		{ desc = "Replace the C/C++ project debug command and run" }
	)
end

return M
