local bufferline = require 'shade.integrations.bufferline'
local cmp = require 'shade.integrations.cmp'
local colorscheme = require 'shade.colorscheme'
local config = require 'shade.config'
local utils = require 'shade.utils'
local theme = {}

local function set_terminal_colors()
	vim.g.terminal_color_0 = colorscheme.editorBackground
	vim.g.terminal_color_1 = colorscheme.syntaxError
	vim.g.terminal_color_2 = colorscheme.successText
	vim.g.terminal_color_3 = colorscheme.warningEmphasis
	vim.g.terminal_color_4 = colorscheme.syntaxFunction
	vim.g.terminal_color_5 = colorscheme.syntaxKeyword
	vim.g.terminal_color_6 = colorscheme.linkText
	vim.g.terminal_color_7 = colorscheme.mainText
	vim.g.terminal_color_8 = colorscheme.inactiveText
	vim.g.terminal_color_9 = colorscheme.errorText
	vim.g.terminal_color_10 = colorscheme.stringText
	vim.g.terminal_color_11 = colorscheme.warningText
	vim.g.terminal_color_12 = colorscheme.syntaxOperator
	vim.g.terminal_color_13 = colorscheme.syntaxError
	vim.g.terminal_color_14 = colorscheme.stringText
	vim.g.terminal_color_15 = colorscheme.commentText
	vim.g.terminal_color_background = colorscheme.editorBackground
	vim.g.terminal_color_foreground = colorscheme.mainText
end

local function set_groups()
	local bg = config.transparent and 'NONE' or colorscheme.editorBackground
	local diff_add =
		 utils.shade(colorscheme.successText, 0.5, colorscheme.editorBackground)
	local diff_delete =
		 utils.shade(colorscheme.syntaxError, 0.5, colorscheme.editorBackground)
	local diff_change =
		 utils.shade(colorscheme.syntaxFunction, 0.5, colorscheme.editorBackground)
	local diff_text =
		 utils.shade(colorscheme.warningEmphasis, 0.5, colorscheme.editorBackground)

	local groups = {
		-- base
		Normal = { fg = colorscheme.mainText, bg = bg },
		LineNr = { fg = colorscheme.lineNumberText },
		ColorColumn = {},
		Conceal = {},
		Cursor = { fg = colorscheme.editorBackground, bg = colorscheme.mainText },
		lCursor = { link = 'Cursor' },
		CursorIM = { link = 'Cursor' },
		CursorLine = { bg = bg },
		CursorColumn = { link = 'CursorLine' },
		Directory = { fg = colorscheme.mainText },
		DiffAdd = { bg = bg, fg = diff_add },
		DiffChange = { bg = bg, fg = diff_change },
		DiffDelete = { bg = bg, fg = diff_delete },
		DiffText = { bg = bg, fg = diff_text },
		EndOfBuffer = { fg = colorscheme.syntaxKeyword },
		TermCursor = { link = 'Cursor' },
		TermCursorNC = { link = 'Cursor' },
		ErrorMsg = { fg = colorscheme.syntaxError },
		VertSplit = { fg = colorscheme.windowBorder, bg = bg },
		Winseparator = { link = 'VertSplit' },
		SignColumn = { link = 'Normal' },
		Folded = { fg = colorscheme.mainText, bg = colorscheme.popupBackground },
		FoldColumn = { link = 'SignColumn' },
		IncSearch = {
			bg = utils.mix(
				colorscheme.mainText,
				colorscheme.editorBackground,
				math.abs(0.30)
			),
			fg = colorscheme.editorBackground,
		},
		Substitute = { link = 'IncSearch' },
		CursorLineNr = { fg = colorscheme.commentText },
		MatchParen = { fg = colorscheme.mainText, bold = true },
		ModeMsg = { link = 'Normal' },
		MsgArea = { link = 'Normal' },
		-- MsgSeparator = {},
		MoreMsg = { fg = colorscheme.mainText },
		NonText = { fg = utils.shade(colorscheme.editorBackground, 0.30) },
		NormalFloat = { bg = bg },
		FloatBorder = { fg = colorscheme.windowBorder },
		NormalNC = { link = 'Normal' },
		Pmenu = { link = 'NormalFloat' },
		PmenuSel = { bg = colorscheme.menuOptionBackground },
		PmenuSbar = {
			bg = utils.shade(
				colorscheme.mainText,
				0.5,
				colorscheme.editorBackground
			),
		},
		PmenuThumb = { bg = utils.shade(colorscheme.editorBackground, 0.20) },
		Question = { fg = colorscheme.mainText },
		QuickFixLine = { fg = colorscheme.mainText },
		SpecialKey = { fg = colorscheme.syntaxOperator },
		StatusLine = { fg = colorscheme.mainText, bg = bg },
		StatusLineNC = {
			fg = colorscheme.inactiveText,
			bg = colorscheme.sidebarBackground,
		},
		TabLine = {
			fg = colorscheme.inactiveText,
			bg = bg,
		},
		TabLineFill = { link = 'TabLine' },
		TabLineSel = {
			fg = colorscheme.emphasisText,
			bg = bg,
		},
		Search = { bg = utils.shade(colorscheme.stringText, 0.40, colorscheme.bg) },
		SpellBad = { undercurl = true, sp = colorscheme.syntaxError },
		SpellCap = { undercurl = true, sp = colorscheme.mainText },
		SpellLocal = { undercurl = true, sp = colorscheme.syntaxKeyword },
		SpellRare = { undercurl = true, sp = colorscheme.warningText },
		Title = { fg = colorscheme.mainText },
		Visual = {
			bg = utils.shade(
				colorscheme.mainText,
				0.40,
				colorscheme.editorBackground
			),
		},
		VisualNOS = { link = 'Visual' },
		WarningMsg = { fg = colorscheme.warningText },
		Whitespace = { fg = colorscheme.syntaxOperator },
		WildMenu = { bg = colorscheme.menuOptionBackground },
		Comment = {
			fg = colorscheme.commentText,
			italic = config.italics.comments or false,
		},

		Constant = { fg = colorscheme.mainText },
		String = {
			fg = colorscheme.stringText,
			italic = config.italics.strings or false,
		},
		Character = { fg = colorscheme.stringText },
		Number = { fg = colorscheme.mainText },
		Boolean = { fg = colorscheme.stringText },
		Float = { link = 'Number' },

		Identifier = { fg = colorscheme.mainText },
		Function = { fg = colorscheme.mainText },
		Method = { fg = colorscheme.mainText },
		Property = { fg = colorscheme.syntaxFunction },
		Field = { link = 'Property' },
		Parameter = { fg = colorscheme.mainText },
		Statement = { fg = colorscheme.stringText, italic = true },
		Conditional = { fg = colorscheme.stringText },
		-- Repeat = {},
		Label = { fg = colorscheme.mainText },
		Operator = { fg = colorscheme.stringText },
		Keyword = { link = 'Statement', italic = config.italics.keywords or false },
		Exception = { fg = colorscheme.syntaxError },

		PreProc = { link = 'Keyword' },
		-- Include = {},
		Define = { fg = colorscheme.mainText },
		Macro = { link = 'Define' },
		PreCondit = { fg = colorscheme.syntaxError },

		Type = { fg = colorscheme.mainText },
		Struct = { link = 'Type' },
		Class = { link = 'Type' },

		-- StorageClass = {},
		-- Structure = {},
		-- Typedef = {},

		Attribute = { fg = colorscheme.stringText },
		Punctuation = { fg = colorscheme.stringText },
		Special = { fg = colorscheme.syntaxOperator },

		SpecialChar = { fg = colorscheme.mainText },
		Tag = { fg = colorscheme.mainText },
		Delimiter = { fg = colorscheme.stringText },
		-- SpecialComment = {},
		Debug = { fg = colorscheme.specialKeyword },

		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Ignore = { fg = colorscheme.editorBackground },
		Error = { link = 'ErrorMsg' },
		Todo = { fg = colorscheme.warningText, bold = true },

		-- LspReferenceText = {},
		-- LspReferenceRead = {},
		-- LspReferenceWrite = {},
		-- LspCodeLens = {},
		-- LspCodeLensSeparator = {},
		-- LspSignatureActiveParameter = {},

		DiagnosticError = { link = 'Error' },
		DiagnosticWarn = { link = 'WarningMsg' },
		DiagnosticInfo = { fg = colorscheme.syntaxFunction },
		DiagnosticHint = { fg = colorscheme.warningEmphasis },
		DiagnosticVirtualTextError = { link = 'DiagnosticError' },
		DiagnosticVirtualTextWarn = { link = 'DiagnosticWarn' },
		DiagnosticVirtualTextInfo = { link = 'DiagnosticInfo' },
		DiagnosticVirtualTextHint = { link = 'DiagnosticHint' },
		DiagnosticUnderlineError = { undercurl = true, sp = colorscheme.errorText },
		DiagnosticUnderlineWarn = { undercurl = true, sp = colorscheme.warningText },
		DiagnosticUnderlineHint = { undercurl = true, sp = "#FFEE8C" },
		DiagnosticUnderlineInfo = { undercurl = true },
		-- DiagnosticUnderlineHint = { undercurl = true, link = 'DiagnosticHint' },
		-- DiagnosticFloatingError = {},
		-- DiagnosticFloatingWarn = {},
		-- DiagnosticFloatingInfo = {},
		-- DiagnosticFloatingHint = {},
		-- DiagnosticSignError = {},
		-- DiagnosticSignWarn = {},
		-- DiagnosticSignInfo = {},
		-- DiagnosticSignHint = {},

		-- Tree-Sitter groups are defined with an "@" symbol, which must be
		-- specially handled to be valid lua code, we do this via the special
		-- sym function. The following are all valid ways to call the sym function,
		-- for more details see https://www.lua.org/pil/5.html
		--
		-- sym("@text.literal")
		-- sym('@text.literal')
		-- sym"@text.literal"
		-- sym'@text.literal'
		--
		-- For more information see https://github.com/rktjmp/lush.nvim/issues/109

		['@text'] = { fg = colorscheme.mainText },
		['@texcolorscheme.literal'] = { link = 'Property' },
		-- ["@texcolorscheme.reference"] = {},
		['@texcolorscheme.strong'] = { link = 'Bold' },
		['@texcolorscheme.italic'] = { link = 'Italic' },
		['@texcolorscheme.title'] = { link = 'Keyword' },
		['@texcolorscheme.uri'] = {
			fg = colorscheme.syntaxFunction,
			sp = colorscheme.syntaxFunction,
			underline = true,
		},
		['@texcolorscheme.underline'] = { link = 'Underlined' },
		['@symbol'] = { fg = colorscheme.syntaxOperator },
		['@texcolorscheme.todo'] = { link = 'Todo' },
		['@comment'] = { link = 'Comment' },
		['@punctuation'] = { link = 'Punctuation' },
		['@punctuation.bracket'] = { fg = colorscheme.stringText },
		['@punctuation.delimiter'] = { link = 'Delimiter' },
		['@punctuation.terminator.statement'] = { link = 'Delimiter' },
		['@punctuation.special'] = { fg = colorscheme.stringText },
		-- ['@punctuation.separator.keyvalue'] = { fg = colorscheme.syntaxError },

		['@texcolorscheme.diff.add'] = { fg = colorscheme.successText },
		['@texcolorscheme.diff.delete'] = { fg = colorscheme.errorText },

		['@constant'] = { link = 'Constant' },
		['@constant.builtin'] = { fg = colorscheme.syntaxFunction },
		['@constancolorscheme.builtin'] = { link = 'Keyword' },
		-- ["@constancolorscheme.macro"] = {},
		-- ["@define"] = {},
		-- ["@macro"] = {},
		['@string'] = { link = 'String' },
		['@string.escape'] = { fg = utils.shade(colorscheme.stringText, 0.45) },
		['@string.special'] = { fg = utils.shade(colorscheme.syntaxFunction, 0.45) },
		-- ["@character"] = {},
		-- ["@character.special"] = {},
		['@number'] = { link = 'Number' },
		['@boolean'] = { link = 'Boolean' },
		-- ["@float"] = {},
		['@function'] = {
			link = 'Function',
			italic = config.italics.functions or false,
		},
		['@function.call'] = { link = 'Function' },
		['@function.builtin'] = { link = 'Function' },
		-- ["@function.macro"] = {},
		['@parameter'] = { link = 'Parameter' },
		['@method'] = { link = 'Function' },
		['@field'] = { link = 'Property' },
		['@property'] = { link = 'Property' },
		['@constructor'] = { fg = colorscheme.mainText },
		['@constructor.lua'] = { fg = colorscheme.stringText },
		-- ["@conditional"] = {},
		-- ["@repeat"] = {},
		['@label'] = { link = 'Label' },
		['@operator'] = { link = 'Operator' },
		['@exception'] = { link = 'Exception' },
		['@variable'] = {
			fg = colorscheme.mainText,
			italic = config.italics.variables or false,
		},
		['@variable.builtin'] = { fg = colorscheme.syntaxFunction },
		['@variable.member'] = { fg = colorscheme.mainText },
		['@variable.parameter'] = {
			fg = colorscheme.mainText,
			italic = config.italics.variables or false,
		},
		['@type'] = { link = 'Type' },
		['@type.definition'] = { fg = colorscheme.mainText },
		['@type.builtin'] = { fg = colorscheme.syntaxFunction },
		['@type.qualifier'] = { fg = colorscheme.syntaxFunction },
		['@keyword'] = { link = 'Keyword' },
		-- ["@storageclass"] = {},
		-- ["@structure"] = {},
		['@namespace'] = { link = 'Type' },
		['@annotation'] = { link = 'Label' },
		-- ["@include"] = {},
		-- ["@preproc"] = {},
		['@debug'] = { fg = colorscheme.specialKeyword },
		['@tag'] = { link = 'Tag' },
		['@tag.builtin'] = { link = 'Tag' },
		['@tag.delimiter'] = { fg = colorscheme.syntaxOperator },
		['@tag.attribute'] = { fg = colorscheme.stringText },
		['@tag.tsx'] = { fg = colorscheme.mainText },
		['@tag.jsx.element'] = { fg = colorscheme.syntaxFunction },
		['@attribute'] = { link = 'Attribute' },
		['@error'] = { link = 'Error' },
		['@warning'] = { link = 'WarningMsg' },
		['@info'] = { fg = colorscheme.syntaxFunction },

		-- Specific languages
		-- overrides
		['@label.json'] = { fg = colorscheme.property }, -- For json
		['@label.help'] = { link = '@texcolorscheme.uri' }, -- For help files
		['@texcolorscheme.uri.html'] = { underline = true }, -- For html

		-- semantic highlighting
		['@lsp.type.namespace'] = { link = '@namespace' },
		['@lsp.type.type'] = { link = '@type' },
		['@lsp.type.class'] = { link = '@type' },
		['@lsp.type.enum'] = { link = '@type' },
		['@lsp.type.enumMember'] = { fg = colorscheme.mainText },
		['@lsp.type.interface'] = { link = '@type' },
		['@lsp.type.struct'] = { link = '@type' },
		['@lsp.type.parameter'] = { link = '@parameter' },
		['@lsp.type.property'] = { link = '@text' },
		['@lsp.type.function'] = { link = '@function' },
		['@lsp.type.method'] = { link = '@method' },
		['@lsp.type.macro'] = { link = '@label' },
		['@lsp.type.decorator'] = { link = '@label' },
		['@lsp.typemod.function.declaration'] = { link = '@function' },
		['@lsp.typemod.function.readonly'] = { link = '@function' },

		rustSigil = { fg = colorscheme.stringText },
		rustFoldBraces = { fg = colorscheme.stringText },
		rustStorage = { fg = colorscheme.stringText },
		rustLifetime = { fg = colorscheme.mainText },
		rustEnumVariant = { fg = colorscheme.mainText },
		['@lsp.type.lifetime.rust'] = { link = '@rustLifetime' },

		SnacksIndent = { fg = colorscheme.windowBorder },

	}

	-- integrations
	groups = vim.tbl_extend('force', groups, cmp.highlights())

	-- overrides
	groups = vim.tbl_extend(
		'force',
		groups,
		type(config.overrides) == 'function' and config.overrides()
		or config.overrides
	)

	for group, parameters in pairs(groups) do
		vim.api.nvim_set_hl(0, group, parameters)
	end
end

function theme.setup(values)
	setmetatable(
		config,
		{ __index = vim.tbl_extend('force', config.defaults, values) }
	)

	theme.bufferline = { highlights = {} }
	theme.bufferline.highlights = bufferline.highlights(config)
end

function theme.colorscheme()
	if vim.version().minor < 8 then
		vim.notify(
			'Neovim 0.8+ is required for shade colorscheme',
			vim.log.levels.ERROR,
			{ title = 'Min Theme' }
		)
		return
	end

	vim.api.nvim_command 'hi clear'
	if vim.fn.exists 'syntax_on' then
		vim.api.nvim_command 'syntax reset'
	end

	vim.g.VM_theme_set_by_colorscheme = true
	vim.o.termguicolors = true
	vim.g.colors_name = 'shade'

	set_terminal_colors()
	set_groups()
end

return theme
