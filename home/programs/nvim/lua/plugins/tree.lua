return {
	{
		"nvim-neo-tree/neo-tree.nvim",

		enabled = true,
		branch = "v3.x",
		lazy = false, -- neo-tree will lazily load itself
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>tt",
				"<cmd>Neotree toggle<cr>",
				desc = "toggle neotree",
			},
			{
				"<leader>tf",
				"<cmd>Neotree action=show<cr>",
				desc = "show files in neotree",
			},
			{
				"<leader>tc",
				"<cmd>Neotree action=close<cr>",
				desc = "close neotree",
			},
			{
				"<leader>tb",
				"<cmd>Neotree action=show source=buffers<cr>",
				desc = "show buffers",
			},
			{
				"<leader>tg",
				"<cmd>Neotree action=show source=git_status<cr>",
				desc = "show changed files",
			},
			{
				"<leader>tr",
				"<cmd>Neotree reveal<cr>",
				desc = "show current file in tree",
			},
		},
		init = function()
			vim.g.neotree_remove_legacy_commands = 1
		end,
		---@module 'neo-tree'
		---@type neotree.Config
		opts = {
			close_if_last_window = true,
			popup_border_style = "",
			enable_git_status = true,
			default_component_configs = {
				git_status = {
					symbols = {
						added = "✚",
						modified = "󰆕 ", -- or ""
						deleted = "󰇘", -- or "✖"
						renamed = "➜",
						untracked = "★",
						ignored = "☒", -- or ""
						unstaged = "", -- or
						staged = "󰄲", -- or "✓"
						conflict = "", -- or ""
					},
				},
			},
		},
		file_size = {
			enabled = true,
			width = 8,
			required_width = 16,
		},
		last_modified = {
			enabled = true,
			width = 17,
			required_width = 80,
		},
		symlink_target = {
			enabled = true,
		},
	},
}
