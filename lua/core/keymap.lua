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

keymap("n", "<leader>d",
	vim.diagnostic.setloclist,
	{ desc = "Diagnostics" }
)

keymap("n", "<leader>t", function()
	vim.cmd("botright 12split")
	vim.cmd("terminal")
	vim.cmd("startinsert")
end, { desc = "Open terminal" })


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
		vim.cmd("enew")
	end
end, { desc = "Close current buffer" })


-- window navigation
keymap('n', '<C-h>', '<C-w>h', {noremap = true})
keymap('n', '<C-j>', '<C-w>j', {noremap = true})
keymap('n', '<C-k>', '<C-w>k', {noremap = true})
keymap('n', '<C-l>', '<C-w>l', {noremap = true})

keymap('n', '<C-Up>', '<C-w><Up>', {noremap = true})
keymap('n', '<C-Down>', '<C-w><Down>', {noremap = true})
keymap('n', '<C-Left>', '<C-w><Left>', {noremap = true})
keymap('n', '<C-Right>', '<C-w><Right>', {noremap = true})
