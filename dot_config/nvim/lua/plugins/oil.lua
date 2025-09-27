return {
	"stevearc/oil.nvim",
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	keys = {
		{ "<leader>op", "<cmd>Oil<cr>", { desc = "open parent directory" } },
	},
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
}
