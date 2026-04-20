return {
	-- Provides cmd/filetype/root_dir defaults for servers not yet bundled
	-- in neovim's runtime. Global setup lives in plugin/lsp.lua.
	-- Per-server overrides live in lsp/*.lua.
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
		"SmiteshP/nvim-navic",
		"b0o/schemastore.nvim",
	},
	config = function()
		-- Must run here (not plugin/lsp.lua) because blink.cmp is not yet
		-- loaded when plugin/ files are sourced at startup.
		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})
	end,
}
