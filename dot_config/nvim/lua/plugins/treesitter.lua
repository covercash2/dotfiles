return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"apple/pkl-neovim",
		},
		init = function()
			vim.cmd("TSUpdate")
			vim.treesitter.language.register("javascript", "dataviewjs")
			vim.treesitter.language.register("json", "dataviewjs")
			vim.treesitter.language.register("gotmpl", "tmpl")
			-- they're close enough, why not
			vim.treesitter.language.register("toml", "conf")
		end,
		opts = {
			ensure_installed = {
				"bash",
				"cpp",
				"css",
				"javascript",
				"json",
				"just",
				"kotlin",
				"lua",
				"make",
				"markdown",
				"markdown_inline",
				"nu",
				"python",
				"rust",
				"svelte",
				"toml",
				"typescript",
				"yaml",
			},
			highlight = {
				enable = true,
			},
		},
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "markdown", "html", "jsx", "svelte", "typescript" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			multiline_threshold = 8,
		},
	},
}
