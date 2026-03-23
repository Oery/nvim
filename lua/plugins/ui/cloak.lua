vim.pack.add({ { src = "https://github.com/laytan/cloak.nvim" } })

-- cloak logins in 42 headers
require("cloak").setup({
	cloak_telescope = true,
	patterns = {
		{
			file_pattern = { '.env*', '*.c', '*.h', '*.cpp', '*.hpp' },
			cloak_pattern = {
				{ '(By:%s+)%S+', replace = '%1' },
				{ '<[^@]+@',     replace = '<' },
				{ '(by%s+)%S+',  replace = '*' },
			},
		}
	},
})
