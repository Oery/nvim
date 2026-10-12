-- Plugin loading that never takes the whole editor down with it, and that is
-- honest about what it is doing.
--
-- Three `vim.pack` behaviours are worked around here:
--
-- 1. It considers a plugin installed as soon as the lockfile has an entry for
--    it (`new_plug()`), not when its files are on disk, so a directory left
--    without a working tree looks installed forever.
-- 2. Its install clones with `--no-checkout` and checks out in a second step,
--    which is another network round trip; when that one fails, `git_cmd()`
--    only turns git's stderr into a notification and the plugin silently stays
--    a checkout-less directory. Plugins are therefore downloaded here, by
--    fetching the revision the lockfile pins with `--depth 1`: one round trip,
--    after which the checkout is purely local.
-- 3. Its progress reporting goes through `nvim_echo`, which does not reach the
--    screen while `init.lua` runs, and which `cmdheight=0` hides as well.
--    Downloads are therefore reported from here, and `plugins/init.lua` moves
--    them to `VimEnter` when there is anything to download.
local M = {}

local problems = {}
local plan = {}
local revs = {}
local failed = {}
local counts = { pending = 0, done = 0, started = 0 }
local armed = false

local function pack_dir()
	return vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
end

local function plugin_path(name)
	return vim.fs.joinpath(pack_dir(), name)
end

local function tmp_path(name)
	return plugin_path(name) .. ".nvim-lite"
end

--- Name `vim.pack` gives a plugin (same derivation as `normalize_spec()`).
local function plugin_name(spec)
	return spec.name or (spec.src:gsub("%.git$", ""):match("[^/]+$") or spec.src)
end

local function has_dir(path)
	local stat = vim.uv.fs_stat(path)
	return stat ~= nil and stat.type == "directory"
end

--- A plugin directory is usable once it holds anything but `.git`.
local function has_files(path)
	if not has_dir(path) then
		return false
	end
	for entry in vim.fs.dir(path) do
		if entry ~= ".git" then
			return true
		end
	end
	return false
end

local function short(msg)
	return (tostring(msg or ""):gsub("%s+$", ""):gsub("%s+", " ")):sub(1, 200)
end

local function show(msg)
	vim.api.nvim_echo({ { msg } }, false, {})
	vim.cmd.redraw()
end

local function counter(done)
	if counts.pending == 0 then
		return ""
	end
	return (" (%d/%d)"):format(done, counts.pending)
end

--- Run git and wait for it.
--- @return table|nil res, string|nil why
local function git(args, cwd)
	local ok, proc = pcall(vim.system, args, { cwd = cwd, text = true })
	if not ok then
		return nil, "git is not usable"
	end

	local res = proc:wait()
	if res.code ~= 0 then
		local msg = short(res.stderr ~= "" and res.stderr or res.stdout)
		return nil, (msg ~= "" and msg) or ("git exited with %d"):format(res.code)
	end

	return res, nil
end

--- Check out a plugin whose clone has no working tree. That needs another round
--- trip for the blobs, which does fail now and then, so it is retried first.
--- @return boolean ok, string|nil why
local function checkout(path, rev)
	local why
	for _ = 1, 3 do
		local ok, err = git({ "git", "-C", path, "checkout", "--quiet", rev })
		if ok and has_files(path) then
			return true, nil
		end
		why = err
		vim.uv.sleep(500)
	end

	return false, why or ("could not check out %s"):format(rev)
end

--- Prepare a download next to its final location, so that a half finished one
--- is never mistaken for an installed plugin.
--- @return table|nil proc, string|nil why
local function start_download(item)
	local tmp = tmp_path(item.name)

	vim.fs.rm(tmp, { recursive = true, force = true })
	vim.fs.rm(item.path, { recursive = true, force = true })
	vim.fn.mkdir(tmp, "p")

	local ok, why = git({ "git", "init", "--quiet", tmp })
	if ok then
		ok, why = git({ "git", "-C", tmp, "remote", "add", "origin", item.src })
	end
	if not ok then
		vim.fs.rm(tmp, { recursive = true, force = true })
		return nil, why
	end

	return vim.system(
		{ "git", "-C", tmp, "fetch", "--quiet", "--depth", "1", "--no-tags", "origin", item.rev },
		{ text = true }
	), nil
end

--- Check out the fetched revision (local) and move the plugin into place.
--- @return boolean ok, string|nil why
local function finish_download(item)
	local tmp = tmp_path(item.name)
	local res = item.proc:wait()
	local why

	if res.code ~= 0 then
		why = short(res.stderr ~= "" and res.stderr or res.stdout)
		if why == "" then
			why = ("git fetch exited with %d"):format(res.code)
		end
	elseif not has_files(tmp) then
		_, why = git({ "git", "-C", tmp, "checkout", "--quiet", "FETCH_HEAD" })
		if not why and not has_files(tmp) then
			why = "nothing was fetched"
		end
	end

	if not why and not vim.uv.fs_rename(tmp, item.path) then
		why = "could not move the download into place"
	end

	if why then
		vim.fs.rm(tmp, { recursive = true, force = true })
		return false, why
	end

	return true, nil
end

--- Plugins that are missing on disk, or downloaded but never checked out.
--- Call once during startup: it builds the work plan and fills the reporting.
function M.pending()
	if armed then
		return counts.pending
	end
	armed = true

	local lock_path = vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")
	local ok, lock = pcall(vim.json.decode, table.concat(vim.fn.readfile(lock_path)) or "{}")
	local locked = (ok and type(lock) == "table" and lock.plugins) or {}

	for name, data in pairs(locked) do
		revs[name] = data.rev or "HEAD"
		local path = plugin_path(name)
		if not has_files(path) then
			plan[#plan + 1] = {
				name = name,
				path = path,
				src = data.src,
				rev = revs[name],
				-- a directory that exists but holds no files is a checkout that
				-- failed earlier: it only needs to be checked out again
				repair = vim.uv.fs_stat(path .. "/.git") ~= nil,
			}
		end
	end

	table.sort(plan, function(a, b)
		return a.name < b.name
	end)
	counts.pending = #plan

	return counts.pending
end

--- Download what is missing: one round trip per plugin, in parallel, with the
--- editor already up so that this is visible.
function M.start()
	if counts.pending == 0 then
		return
	end

	counts.started = vim.uv.hrtime()
	vim.notify(
		("nvim-lite: setting up %d plugin(s), this only happens once; the editor is busy until it is done")
			:format(counts.pending),
		vim.log.levels.INFO
	)

	for _, item in ipairs(plan) do
		if item.repair then
			show(("nvim-lite: checking out %s"):format(item.name))
		else
			item.proc, item.error = start_download(item)
			if not item.error then
				show(("nvim-lite: fetching %s"):format(item.name))
			end
		end
	end

	for _, item in ipairs(plan) do
		local ok, why
		if item.error then
			ok, why = false, item.error
		elseif item.repair then
			ok, why = checkout(item.path, item.rev)
		else
			ok, why = finish_download(item)
		end

		counts.done = counts.done + 1
		if ok then
			show(("nvim-lite: %s ready%s"):format(item.name, counter(counts.done)))
		else
			-- the directory is left as it is, so a broken network does not turn
			-- into downloading everything again on every launch. Something that
			-- is not a git repository at all can not be checked out later,
			-- though, so it is dropped to be downloaded again instead.
			if item.repair and not git({ "git", "-C", item.path, "rev-parse", "--git-dir" }) then
				vim.fs.rm(item.path, { recursive = true, force = true })
			end
			failed[item.name] = why
			problems[#problems + 1] = ("%s: %s"):format(item.name, why)
			show(("nvim-lite: %s failed%s"):format(item.name, counter(counts.done)))
		end
	end
end

--- Hand a plugin to `vim.pack` and return the module it is set up through.
--- @param spec vim.pack.Spec
--- @param module string entry module of the plugin
--- @return table|nil module, nil when the plugin is unavailable
function M.load(spec, module)
	local name = plugin_name(spec)
	local path = plugin_path(name)

	-- already reported by `M.start()`; letting `vim.pack` retry the same
	-- download would only add a checkout-less directory to the pack dir
	if failed[name] then
		return nil
	end

	local ok, err = pcall(vim.pack.add, { spec }, { confirm = false })
	if not ok then
		problems[#problems + 1] = ("%s: %s"):format(name, short(err))
		return nil
	end

	-- 1. above: a directory without files is treated as installed, so it is
	-- checked out here instead of being downloaded again
	if not has_files(path) then
		show(("nvim-lite: checking out %s"):format(name))
		local repaired, why = checkout(path, revs[name] or "HEAD")
		if not repaired then
			problems[#problems + 1] = ("%s: %s"):format(name, why)
			return nil
		end
	end

	local loaded, mod = pcall(require, module)
	if not loaded then
		problems[#problems + 1] = ("%s: %s is not loadable"):format(name, module)
		return nil
	end

	return mod
end

--- Whether a module was loaded through `M.load()`, e.g. to know if a keymap
--- relying on that plugin may be defined.
--- @param module string
--- @return boolean
function M.has(module)
	return package.loaded[module] ~= nil
end

--- Report what happened, once, without a traceback.
function M.report()
	if counts.done > 0 and counts.started > 0 then
		local secs = (vim.uv.hrtime() - counts.started) / 1e9
		vim.notify(
			("nvim-lite: %d/%d plugin(s) ready in %.1fs"):format(counts.done - #problems, counts.pending, secs),
			vim.log.levels.INFO
		)
	end

	if #problems == 0 then
		return
	end

	vim.notify(
		("nvim-lite: %d plugin(s) unavailable, editing still works; check network/git:\n  %s")
			:format(#problems, table.concat(problems, "\n  ")),
		vim.log.levels.WARN
	)
end

return M
