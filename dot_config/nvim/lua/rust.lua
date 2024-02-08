rust = {
	'simrat39/rust-tools.nvim',
	dependencies = {
		'neovim/nvim-lspconfig',
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
	},
	opts = {
	},
	config = function()
		local lsp_attach = function(client, buf_num)
			local function buf_set_option(...) vim.api.nvim_buf_set_option(buf_num, ...) end
			buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

			vim.o.updatetime = 250

			vim.api.nvim_create_autocmd("CursorHold", {
				buffer = buf_num,
				callback = function()
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						border = 'rounded',
						source = 'always',
						prefix = ' ',
						scope = 'cursor',
					}
					vim.diagnostic.open_float(nil, opts)
				end
			})
		end

		local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

		local rt = require('rust-tools')

		rt.setup({
			server = {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- code action groups
					vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
					-- hover action
					vim.keymap.set("n", "<Leader><Leader>", rt.hover_actions.hover_actions, { buffer = bufnr })

					lsp_attach(client, bufnr)
				end
			},
			hover_actions = {
				auto_focus = true,
			},
		})

		rt.hover_range.hover_range()

	end
}
