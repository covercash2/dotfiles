return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/obsidian/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/obsidian/**.md",
	},
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
		min_chars = 1,
	},
}
