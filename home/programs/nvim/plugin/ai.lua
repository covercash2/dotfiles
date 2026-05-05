-- Copilot
require("copilot").setup({
	copilot_model = "",
	suggestion = {
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<Tab>",
		},
	},
	nes = {
		enabled = false,
		keymap = {
			accept_and_goto = "<leader>p",
			accept = false,
			dismiss = "<Esc>",
		},
	},
	panel = {
		auto_refresh = true,
	},
	filetypes = {
		markdown = true,
		text = true,
		["*"] = true,
	},
})

-- Hide copilot suggestions when blink completion menu is open
vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		vim.b.copilot_suggestion_hidden = true
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function()
		vim.b.copilot_suggestion_hidden = false
	end,
})

vim.keymap.set("n", "<leader>ap", function()
	require("copilot.panel").toggle()
end, { desc = "toggle Copilot panel" })

-- Avante
require("avante").setup({
	provider = "copilot",
	instructions_file = "AGENTS.md",
})

vim.keymap.set("n", "<leader>at", function()
	vim.cmd("AvanteToggle")
end, { desc = "toggle Avante" })

-- img-clip (image pasting for avante)
require("img-clip").setup({
	default = {
		embed_image_as_base64 = false,
		prompt_for_file_name = false,
		drag_and_drop = {
			insert_mode = true,
		},
		use_absolute_file_path = true,
	},
})

-- render-markdown (for avante + markdown buffers)
require("render-markdown").setup({
	file_types = { "markdown", "Avante" },
})
