local lsp_config = {
	"neovim/nvim-lspconfig",
	dependencies = {
		"nvim-lua/completion-nvim",
	},
	config = function()
		local nvim_lsp = require("lspconfig")
		local servers = {
			"biome", -- javascript stuff
			"eslint",
			"html",
			"luau_lsp",
			"lua_ls",
			"pyright",
			"svelte",
			"ts_ls",
		}
		local on_attach = function(client, bufnr)
			-- show a window when a doc is available
			auto_show_hover(bufnr)

			local function buf_set_keymap(...)
				vim.api.nvim_buf_set_keymap(bufnr, ...)
			end
			local function buf_set_option(...)
				vim.api.nvim_buf_set_option(bufnr, ...)
			end

			buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

			local opts = { noremap = true, silent = true }

			buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
			buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
			buf_set_keymap(
				"n",
				"<leader>wl",
				"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
				opts
			)
			buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
			buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
		end

		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		for _, server in ipairs(servers) do
			nvim_lsp[server].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end
	end,
}
