vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig" } })

vim.lsp.inlay_hint.enable(true)

require("lsp.rust")
require("lsp.lua_ls")
require("lsp.web")
require("lsp.python")

vim.lsp.enable("qmlls")
vim.lsp.enable("biome")
vim.lsp.enable('csharp_ls')
vim.lsp.enable('clangd')
