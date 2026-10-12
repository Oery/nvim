<h1 align="center">Shade.nvim</h1>

<p align="center">A hight contrast monochromatic colorscheme for Neovim</p>

<p align="center">
  <img height="400" alt="Preview Screenshot" src="https://github.com/user-attachments/assets/b3350f4a-1841-4379-a9eb-04e6f5b38297"/>
</p>

## Install

###### Installation
```lua
vim.pack.add({{ src = "https://github.com/oery/shade.nvim"}});
```

###### Configuration
```lua
require('shade').setup {
	theme = 'dark',
	transparent = true,
}
```

###### Set Colorscheme
```lua
vim.cmd(':colorscheme shade')
```

## Credits

- The theme was originally a port of the VsCode R Dark Pro theme with black and white filter.
