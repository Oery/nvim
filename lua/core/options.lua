vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 5

vim.o.wrap = false
vim.o.linebreak = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"

vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.o.scrolloff = 10
vim.o.winborder = "rounded"
vim.opt.fillchars = { eob = " " }
vim.o.splitkeep = "screen"
vim.o.clipboard = "unnamedplus"

---@type vim.DiagnosticConfig
local diagnostic_config = {
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
        },
    },
}
vim.diagnostic.config(diagnostic_config)

vim.g.user42 = vim.env.USER_42
vim.g.mail42 = vim.env.GIT_AUTHOR_EMAIL
