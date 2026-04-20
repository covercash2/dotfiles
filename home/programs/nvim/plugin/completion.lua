require("blink.cmp").setup({
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
				score_offset = 90,
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

	fuzzy = { implementation = "prefer_rust_with_warning" },
})
