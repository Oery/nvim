vim.pack.add({ { src = "https://github.com/nvim-mini/mini.nvim" } }, { confirm = false })

local surround = require("mini.surround")

surround.setup()
