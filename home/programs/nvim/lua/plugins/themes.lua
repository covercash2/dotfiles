return {
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppucin",
		priority = 1000,
		lazy = false,
		config = function()
			vim.cmd.colorscheme("kanagawa")
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		-- lazy = false,
		-- config = function()
		-- 	vim.cmd.colorscheme("kanagawa")
		-- end,
	},
}
