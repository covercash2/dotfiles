return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			-- v for version/git
			{
				"<leader>vc",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "list git commits",
			},
			{
				"<leader>vd",
				function()
					require("telescope.builtin").git_bcommits()
				end,
				desc = "list git commits for this buffer",
			},
			{
				"<leader>vb",
				function()
					require("telescope.builtin").git_branches()
				end,
				desc = "list git branches",
			},
			{
				"<leader>vs",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "list git branches",
			},

			-- f for find
			{
				"<leader>fG",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "find string in files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "search in files",
			},
			{
				"<leader>fS",
				function()
					require("telescope.builtin").spell_suggest()
				end,
				desc = "fix spelling",
			},

			-- r for run
			{
				"<leader>rc",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "list commands",
			},
			{
				"<leader>rh",
				function()
					require("telescope.builtin").command_history()
				end,
				desc = "list recent commands",
			},

			-- s for settings
			{
				"<leader>sc",
				function()
					require("telescope.builtin").colorscheme()
				end,
				desc = "list colorschemes",
			},
			{
				"<leader>sm",
				function()
					require("telescope.builtin").man_pages()
				end,
				desc = "search man pages",
			},
			{
				"<leader>so",
				function()
					require("telescope.builtin").vim_options()
				end,
				desc = "list vim options",
			},
			{
				"<leader>sq",
				function()
					require("telescope.builtin").quickfix()
				end,
				desc = "list quickfixes",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					-- default config here
				},
				pickers = {
					find_files = {
						-- include hidden files not in .git
						find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
					},
					commands = {
						theme = "cursor",
					},
					colorscheme = {
						theme = "dropdown",
					},
					live_grep = {
						theme = "dropdown",
					},
					spell_suggest = {
						theme = "cursor",
					},
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope-dap.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("dap")
		end,
	},
}
