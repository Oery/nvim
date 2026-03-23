vim.lsp.enable("lua_ls")

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "Neovim >= 0.10" },
            workspace = {
                checkThirdParty = false,
                trust = true,
            },
            diagnostics = {
                disable = { "missing-fields" },
            },
        },
    },
})
