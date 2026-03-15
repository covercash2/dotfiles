return {
	"obsidian-nvim/obsidian.nvim",

	version = "*",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"saghen/blink.cmp",
	},
	ft = { "markdown" },
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		workspaces = {
			{
				name = "core",
				path = "~/obsidian/core",
			},
			{
				name = "work",
				path = "~/obsidian/work",
			},
			{
				name = "DnD",
				path = "~/obsidian/DnD/",
			},
		},
	},
	completion = {
		blink = true,
		nvim_cmp = false,
		min_chars = 1,
	},
}
