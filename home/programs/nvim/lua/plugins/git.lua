return {
	"tpope/vim-fugitive",
	{
		"f-person/git-blame.nvim",

		keys = {
			{ "<leader>vB", "<cmd>GitBlameToggle<cr>", desc = "toggle git blame" },
		},
		opts = {},
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},
	"akinsho/git-conflict.nvim",
	{
		"almo7aya/openingh.nvim",
	},
}
