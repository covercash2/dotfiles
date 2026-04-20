-- Register custom language associations
vim.treesitter.language.register("javascript", "dataviewjs")
vim.treesitter.language.register("json", "dataviewjs")
vim.treesitter.language.register("gotmpl", "tmpl")
vim.treesitter.language.register("toml", "conf")

-- Autotag (auto close/rename HTML tags)
require("nvim-ts-autotag").setup()

-- Treesitter context (sticky function headers)
require("treesitter-context").setup({
	multiline_threshold = 8,
})

-- Treesitter keymaps
local map = vim.keymap.set
map("n", "<leader>Tg", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "go to context" })
map("n", "<leader>Ts", require("telescope.builtin").treesitter, { desc = "structure (treesitter)" })

-- Rainbow delimiters
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
