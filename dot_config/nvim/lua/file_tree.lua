local lazy_config = {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		-- disable legacy commands
		vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1]])
		require('neo-tree').setup({
			close_if_last_window = true,
		})
	end,
}

local function focus_neotree ()
	require("neo-tree")
	vim.cmd("Neotree action=focus")
end

local function close_neotree ()
	require('neo-tree')
	vim.cmd("Neotree action=close")
end

local file_tree = {
	lazy = lazy_config,
	show = focus_neotree,
	close = close_neotree,
}

return file_tree
