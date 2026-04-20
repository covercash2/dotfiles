-- Mini modules
require("mini.ai").setup({})
require("mini.surround").setup({})
require("mini.indentscope").setup({})
require("mini.trailspace").setup({})
require("mini.comment").setup({})

-- Autoclose (brackets, quotes, etc.)
require("autoclose").setup({
	keys = {
		["<"] = { escape = false, close = true, pair = "<>" },
		["'"] = { escape = true, close = false, pair = "''", disabled_filtetypes = { "rust" } },
	},
	options = {
		disable_when_touch = true,
		pair_spaces = true,
	},
})

-- Comment.nvim
require("Comment").setup({})

-- todo-comments
require("todo-comments").setup({})

-- Fidget (LSP progress)
require("fidget").setup()

-- Scrollview
require("scrollview").setup({
	current_only = false,
	signs_on_startup = {
		"search",
		"diagnostics",
		"marks",
		"cursor",
		"conflicts",
		"latestchange",
	},
})

-- Notify
require("notify").setup({
	timeout = 1500,
})

-- nvim-web-devicons
require("nvim-web-devicons").setup({
	default = true,
})

-- Flash
require("flash").setup({
	modes = {
		search = {
			enabled = true,
			jump = { nohlsearch = false },
		},
	},
	label = {
		rainbow = {
			enabled = true,
			shade = 5,
		},
	},
})

local map = vim.keymap.set
-- stylua: ignore start
map({ "n", "x", "o" }, "<leader>fs", function() require("flash").jump() end, { desc = "flash" })
map({ "n", "x", "o" }, "<leader>fS", function() require("flash").treesitter() end, { desc = "flash Treesitter" })
map("o", "<leader>fr", function() require("flash").remote() end, { desc = "remote Flash" })
map({ "o", "x" }, "<leader>fR", function() require("flash").treesitter_search() end, { desc = "treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "toggle Flash Search" })
map({ "n", "x", "o" }, "<leader>fw", function()
	require("flash").jump({ pattern = vim.fn.expand("<cword>") })
end, { desc = "flash Word Under Cursor" })
-- stylua: ignore end

-- Close buffers
local close_buffers = require("close_buffers")
map("n", "<leader>bh", function()
	close_buffers.delete({ type = "hidden" })
end, { desc = "close hidden buffers" })
map("n", "<leader>bo", function()
	close_buffers.delete({ type = "other" })
end, { desc = "close other buffers" })
map("n", "<leader>bc", function()
	close_buffers.delete({ type = "this" })
end, { desc = "close this buffer" })

-- Spider (subword motions)
require("spider").setup({
	skipInsignificantPunctuation = true,
	subwordMovement = true,
})

map({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "move to the start of the next subword" })
map({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "move to the end of the next subword" })
map({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "move to the start of the previous subword" })
