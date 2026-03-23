vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
})

local dap = require("dap")
local dvt = require("nvim-dap-virtual-text")

dap.defaults.fallback.external_terminal = {
	command = "ghostty",
	args = { "--title=dap-term", "-e" },
}

dap.listeners.after.launch["resize-dap-term"] = function(_, _)
	vim.fn.system("hyprctl dispatch resizeactive exact 1200 100%")
end

dvt.setup({})

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

vim.api.nvim_set_hl(0, "DebugSymbol", { fg = "#22863a" })
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DebugSymbol" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DebugSymbol" })
vim.fn.sign_define("DapStopped", { text = " ", texthl = "DebugSymbol" })
