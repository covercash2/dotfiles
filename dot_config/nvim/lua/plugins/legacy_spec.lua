return {
	{
		-- auto close pairs, brackets, parentheses, quotes, etc
		"m4xshen/autoclose.nvim",
		opts = {
			keys = {
				["<"] = { escape = false, close = true, pair = "<>" },
				["'"] = { escape = true, close = false, pair = "''", disabled_filtetypes = { "rust" } },
			},
			options = {
				disable_when_touch = true,
				pair_spaces = true,
			},
		},
	},
	{
		"andrewradev/linediff.vim",
	},
	{
		"metakirby5/codi.vim",
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		opts = {},
	},
	{ "echasnovski/mini.icons", version = false },
	{
		"echasnovski/mini.surround",
		version = "*",
		lazy = false,
		opts = {},
	},
	{
		"echasnovski/mini.indentscope",
		version = "*",
		lazy = false,
		opts = {},
	},
	{
		"echasnovski/mini.trailspace",
		version = "*",
		lazy = false,
		opts = {},
	},
	{
		"echasnovski/mini.comment",
		version = "*",
		lazy = false,
		opts = {},
	},
	-- svelte
	{
		"leafOfTree/vim-svelte-plugin",
		init = function()
			vim.g.vim_svelte_plugin_load_full_syntax = 1
			vim.g.vim_svelte_plugin_use_typescript = 1
		end,
		opts = {},
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		config = true,
	},
	{
		"dstein64/nvim-scrollview",
		opts = {
			current_only = false,
			signs_on_startup = {
				"search",
				"diagnostics",
				"marks",
				"cursor",
				"conflicts",
				"latestchange",
			},
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 1500,
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			default = true,
		},
	},
	{
		"oysandvik94/curl.nvim",
		cmd = { "CurlOpen" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
	},
	{ "vuciv/golf" },
}
