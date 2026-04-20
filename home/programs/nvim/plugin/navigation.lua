-- Oil (file browser)
require("oil").setup({})

vim.keymap.set("n", "<leader>op", "<cmd>Oil<cr>", { desc = "open parent directory" })

-- Telescope
require("telescope").setup({
	defaults = {},
	pickers = {
		find_files = {
			-- include hidden files not in .git
			find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
		},
		commands = {
			theme = "cursor",
		},
		colorscheme = {
			theme = "dropdown",
		},
		live_grep = {
			theme = "dropdown",
		},
		spell_suggest = {
			theme = "cursor",
		},
	},
})

require("telescope").load_extension("ui-select")
require("telescope").load_extension("dap")

-- Telescope keymaps
local map = vim.keymap.set
local tb = require("telescope.builtin")

-- v for version/git
map("n", "<leader>vc", tb.git_commits, { desc = "list git commits" })
map("n", "<leader>vd", tb.git_bcommits, { desc = "list git commits for this buffer" })
map("n", "<leader>vb", tb.git_branches, { desc = "list git branches" })
map("n", "<leader>vs", tb.git_status, { desc = "list git status" })

-- f for find
map("n", "<leader>fG", tb.grep_string, { desc = "find string in files" })
map("n", "<leader>fg", tb.live_grep, { desc = "search in files" })
map("n", "<leader>fS", tb.spell_suggest, { desc = "fix spelling" })

-- r for run
map("n", "<leader>rc", tb.commands, { desc = "list commands" })
map("n", "<leader>rh", tb.command_history, { desc = "list recent commands" })

-- s for settings
map("n", "<leader>sc", tb.colorscheme, { desc = "list colorschemes" })
map("n", "<leader>sm", tb.man_pages, { desc = "search man pages" })
map("n", "<leader>so", tb.vim_options, { desc = "list vim options" })
map("n", "<leader>sq", tb.quickfix, { desc = "list quickfixes" })
