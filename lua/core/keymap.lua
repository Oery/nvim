local keymap = vim.keymap.set

-- set leader to spacebar
vim.g.mapleader = " "

-- alias ';' to ':' to avoid need to press shift
keymap({ "n", "v", "s" },
	";", ":",
	{ nowait = true }
)

keymap("n", "<leader>o",
	":update<CR> :source<CR>",
	{ desc = "Source file" }
)

keymap("n", "<leader>e",
	":Neotree reveal right<CR>",
	{ desc = "File tree" }
)

keymap("n", "<leader>ff",
	":Telescope find_files<CR>",
	{ desc = "File picker" }
)

keymap("n", "<leader>fw",
	":Telescope live_grep<CR>",
	{ desc = "Live grep" }
)

keymap("n", "<leader>s",
	":Telescope lsp_dynamic_workspace_symbols<CR>",
	{ desc = "Symbols" }
)

keymap("n", "<leader>ld",
	":Trouble diagnostics<CR>",
	{ desc = "Diagnostics" }
)


-- snacks
local snacks = require("snacks")

keymap("n", "<leader>t",
	function() snacks.terminal() end,
	{ desc = "Open terminal" }
)


-- cokeline
local buffers = require("cokeline.buffers")

keymap("n", "<S-Tab>",
	"<Plug>(cokeline-focus-prev)",
	{ silent = true, desc = "Focus previous tab" }
)

keymap("n", "<Tab>",
	"<Plug>(cokeline-focus-next)",
	{ silent = true, desc = "Focus next tab" }
)

keymap("n", "<leader>x", function(_)
	buffers.get_current():delete()

	if #buffers.get_visible() == 0 then
		snacks.dashboard.open()
	end
end, { desc = "Close current buffer" })


-- debugging / dap
local dap = require("dap")

keymap("n", "<leader>1",
	dap.continue,
	{ desc = "Continue" }
)

keymap("n", "<leader>2",
	dap.toggle_breakpoint,
	{ desc = "Toggle Breakpoint" }
)

keymap("n", "<leader>3",
	dap.run_to_cursor,
	{ desc = "Run to Cursor" }
)

keymap("n", "<leader>4",
	dap.step_into,
	{ desc = "Step Into" }
)

keymap("n", "<leader>5",
	dap.step_over,
	{ desc = "Step Over" }
)

keymap("n", "<leader>6",
	dap.step_out,
	{ desc = "Step Out" }
)

keymap("n", "<leader>-",
	dap.restart,
	{ desc = "Restart" }
)

keymap("n", "<leader>=",
	dap.terminate,
	{ desc = "Terminate" }
)


-- blink.cmp
local blink = require("blink.cmp")

keymap("i", "<S-space>",
	blink.show,
	{ desc = "Open Completion" }
)


-- treesitter objects
local ts_objects = require("nvim-treesitter-textobjects.select")

keymap({ "x", "o" }, "af", function()
	ts_objects.select_textobject("@function.outer", "textobjects")
end)

keymap({ "x", "o" }, "if", function()
	ts_objects.select_textobject("@function.inner", "textobjects")
end)
