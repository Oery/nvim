-- Plugin loading that never takes the whole editor down with it.
--
-- `vim.pack` treats a plugin as installed as soon as the lockfile has an entry
-- for it (`new_plug()` in `vim/pack.lua`), not when its files are on disk. A
-- directory left behind without a working tree -- an aborted
-- `git clone --no-checkout`, e.g. when the first install gets interrupted --
-- therefore looks installed forever and only shows up as a fatal
-- "module 'x' not found" in `init.lua`. Those directories are deleted here so
-- that `vim.pack` clones them again, and anything that still can not be loaded
-- is reported once instead of raising.
local M = {}

local problems = {}
local failed_srcs = {}

local function pack_dir()
	return vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
end

-- Delete plugin directories that hold nothing but `.git` (or nothing at all).
local function drop_ghosts()
	local dir = pack_dir()
	if vim.uv.fs_stat(dir) == nil then
		return
	end

	for name, kind in vim.fs.dir(dir) do
		if kind == "directory" then
			local path = vim.fs.joinpath(dir, name)
			local empty = true
			for entry in vim.fs.dir(path) do
				if entry ~= ".git" then
					empty = false
					break
				end
			end
			if empty then
				vim.fs.rm(path, { recursive = true, force = true })
			end
		end
	end
end

--- Install a plugin if needed and return the module it is set up through.
--- @param spec vim.pack.Spec
--- @param module string entry module of the plugin
--- @return table|nil module, nil when the plugin is unavailable
function M.load(spec, module)
	-- Several files can ask for the same plugin (mini.nvim); retrying a source
	-- that just failed only makes a missing network hurt more.
	if failed_srcs[spec.src] then
		return nil
	end

	if not pcall(vim.pack.add, { spec }, { confirm = false }) then
		failed_srcs[spec.src] = true
		problems[#problems + 1] = ("%s: download failed"):format(spec.src)
		return nil
	end

	local ok, loaded = pcall(require, module)
	if not ok then
		problems[#problems + 1] = ("%s: %s is not loadable"):format(spec.src, module)
		return nil
	end

	return loaded
end

--- Whether a module was loaded through `M.load()`, e.g. to know if a keymap
--- relying on that plugin may be defined.
--- @param module string
--- @return boolean
function M.has(module)
	return package.loaded[module] ~= nil
end

--- Report every unavailable plugin once, without a traceback.
function M.report()
	if #problems == 0 then
		return
	end

	vim.notify(
		("nvim-lite: %d plugin(s) unavailable, editing still works; check git/network, then restart nvim:\n  %s")
			:format(#problems, table.concat(problems, "\n  ")),
		vim.log.levels.WARN
	)
end

drop_ghosts()

return M
