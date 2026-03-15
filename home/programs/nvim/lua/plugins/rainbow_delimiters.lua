return {
	url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local rainbow_delimiters = require("rainbow-delimiters")
		require("rainbow-delimiters.setup").setup({
			strategy = {
				[""] = rainbow_delimiters.strategy["global"],
				vim = rainbow_delimiters.strategy["local"],
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
			priority = {
				[""] = 110,
				lua = 210,
			},
			highlight = {
				"RainbowDelimiterGreen",
				"RainbowDelimiterCyan",
				"RainbowDelimiterBlue",
				"RainbowDelimiterViolet",
				"RainbowDelimiterGreen",
				"RainbowDelimiterCyan",
				"RainbowDelimiterBlue",
				"RainbowDelimiterViolet",
				"RainbowDelimiterYellow",
				"RainbowDelimiterOrange",
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterOrange",
				"RainbowDelimiterRed",
			},
		})
	end,
}
