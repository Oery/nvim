vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
})

local dap = require("dap")
local dvt = require("nvim-dap-virtual-text")
local dap_view = require("dap-view")

dvt.setup({})

dap_view.setup({
	auto_toggle = "keep_terminal",
	winbar = {
		default_section = "threads",
		base_sections = {
			threads = { label = "Call Stack", keymap = "T" },
		},
	},
	windows = {
		-- Stack above, program terminal below, in one right-hand panel.
		position = "right",
		size = 100,
		terminal = { position = "below", size = 0.5 },
	},
})

dap.adapters.codelldb = require("debug.adapters.codelldb")
dap.adapters.debugpy = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.c = require("debug.configs.cpp")
dap.configurations.cpp = require("debug.configs.cpp")
dap.configurations.rust = require("debug.configs.rust")
dap.configurations.python = require("debug.configs.python")

require("debug.project").setup()

vim.api.nvim_set_hl(0, "DebugSymbol", { fg = "#22863a" })
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DebugSymbol" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DebugSymbol" })
vim.fn.sign_define("DapStopped", { text = " ", texthl = "DebugSymbol" })
