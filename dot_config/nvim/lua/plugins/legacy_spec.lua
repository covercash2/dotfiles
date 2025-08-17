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
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			default = true,
		},
	},
	{
		"andythigpen/nvim-coverage",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local get_lcov_file = function()
				local file = vim.fn.expand("%:p")
				if string.find(file, "/packages/") then
					local match = string.match(file, "(.-/[^/]+/)coverage") .. "lcov.info"
					print("using coverage report: ", match)
					if vim.fn.filereadable(match) then
						return match
					else
						print("file did not match expected: ", match)
					end
				end
				print("no coverage file found")
			end

			require("coverage").setup({
				lcov_file = get_lcov_file,
			})
		end,
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
