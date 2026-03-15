local auto_show_hover = function(bufnr)
	-- show a window when a doc is available
	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			}
			vim.diagnostic.open_float(opts)
		end,
	})
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
		"SmiteshP/nvim-navic",
		"b0o/schemastore.nvim",
	},
	opts = {
		servers = {
			lua_ls = {},
			-- https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
			typos_lsp = {
				cmd_env = { RUST_LOG = "error" },
				init_options = {
					diagnositSeverity = "Error",
				},
			},
		},
	},
	config = function()
		local servers = {
			"biome", -- javascript stuff
			"eslint",
			"helm_ls",
			"html",
			"luau_lsp",
			"lua_ls",
			"nil_ls",
			"nushell",
			"postgres_lsp",
			"pyright",
			"ruff",
			"svelte",
			"taplo",
			"ts_ls",
		}
		local navic = require("nvim-navic")
		local on_attach = function(client, bufnr)
			-- show a window when a doc is available
			auto_show_hover(bufnr)

			-- get file navigation info
			if client.server_capabilities.documentSymbolProvider then
				navic.attach(client, bufnr)
			end
		end

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		for _, server in ipairs(servers) do
			vim.lsp.config[server] = {
				on_attach = on_attach,
				capabilities = capabilities,
			}
		end
	end,
}
