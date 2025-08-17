return {
	"stevearc/oil.nvim",
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	keys = {
		{ "<leader>op", "<cmd>Oil<cr>", { desc = "open parent directory" } },
	},
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
}
