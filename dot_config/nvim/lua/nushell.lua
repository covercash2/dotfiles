local plugin = {
	"LhKipp/nvim-nu",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
	},
	build = ':TSInstall nu',
	opts = {
		use_lsp_features = false,
	}
}

return {
	spec = plugin
}
