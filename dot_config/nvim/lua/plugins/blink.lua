return {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "enter" },

			completion = { documentation = { auto_show = true } },
			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"buffer",
					-- https://github.com/yetone/avante.nvim?tab=readme-ov-file#configuration-example
					"avante_commands",
					"avante_mentions",
					"avante_shortcuts",
					"avante_files",
				},
				providers = {
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90, -- higher priority than LSP
						opts = {},
					},
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					avante_shortcuts = {
						name = "avante_shortcuts",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"saghen/blink.compat",
		-- v2.* for blink.cmp 1.*
		version = "2.*",
		lazy = true,
		opts = {},
	},
}
