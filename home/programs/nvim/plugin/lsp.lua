-- Global capabilities for all LSP servers.
-- blink.cmp is available here because vim.pack.add() loaded it in init.lua.
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Auto-show diagnostics on cursor hold.
-- Uses a named augroup per buffer to deduplicate across multiple LSP clients.
local function auto_show_hover(bufnr)
	local group = vim.api.nvim_create_augroup("LspAutoHover_" .. bufnr, { clear = true })
	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		buffer = bufnr,
		callback = function()
			vim.diagnostic.open_float({
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			})
		end,
	})
end

-- LspAttach replaces the deprecated on_attach callback.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf

		auto_show_hover(bufnr)

		-- breadcrumbs / winbar navigation
		if client and client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

-- LSP keymaps
local map = vim.keymap.set
map("n", "<leader>bf", vim.lsp.buf.format, { desc = "format buffer" })
map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "type definition" })
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "definition" })
map("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "declaration" })
map("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "implementation" })
map("n", "<leader>gr", vim.lsp.buf.references, { desc = "references" })
map("n", "<leader>h", vim.lsp.buf.hover, { desc = "hover window" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "code action" })
map("n", "<leader>lA", vim.lsp.buf.add_workspace_folder, { desc = "add workspace" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "rename" })
map("n", "<leader>lR", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "signature help" })

-- Enable servers. Per-server overrides live in lsp/*.lua.
vim.lsp.enable({
	"biome",
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
	"typos_lsp",
	"yamlls",
})
