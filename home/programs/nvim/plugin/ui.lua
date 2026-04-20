-- Theme
vim.cmd.colorscheme("kanagawa")

-- Lualine
local function recording_symbol()
	local register = vim.fn.reg_recording()
	if register == "" then
		return ""
	end
	return "󰑋 " .. register
end

require("lualine").setup({
	theme = "auto",
	sections = {
		lualine_c = {
			function()
				return vim.api.nvim_buf_get_name(0)
			end,
		},
		lualine_x = {
			recording_symbol,
		},
	},
})

-- Winbar (breadcrumbs via navic)
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

-- Window picker
require("window-picker").setup({
	hint = "floating-big-letter",
	prompt_message = "pick window: ",
})

-- Neo-tree
vim.g.neotree_remove_legacy_commands = 1

require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "",
	enable_git_status = true,
	default_component_configs = {
		git_status = {
			symbols = {
				added = "✚",
				modified = "󰆕 ",
				deleted = "󰇘",
				renamed = "➜",
				untracked = "★",
				ignored = "☒",
				unstaged = "",
				staged = "󰄲",
				conflict = "",
			},
		},
	},
})

local map = vim.keymap.set
map("n", "<leader>tt", "<cmd>Neotree toggle<cr>", { desc = "toggle neotree" })
map("n", "<leader>tf", "<cmd>Neotree action=show<cr>", { desc = "show files in neotree" })
map("n", "<leader>tc", "<cmd>Neotree action=close<cr>", { desc = "close neotree" })
map("n", "<leader>tb", "<cmd>Neotree action=show source=buffers<cr>", { desc = "show buffers" })
map("n", "<leader>tg", "<cmd>Neotree action=show source=git_status<cr>", { desc = "show changed files" })
map("n", "<leader>tr", "<cmd>Neotree reveal<cr>", { desc = "show current file in tree" })

-- Obsidian (only load when at least one vault exists on this machine)
local obsidian_workspaces = {
	{ name = "core", path = "~/obsidian/core" },
	{ name = "work", path = "~/obsidian/work" },
	{ name = "DnD", path = "~/obsidian/DnD" },
}

local available = vim.tbl_filter(function(ws)
	return vim.fn.isdirectory(vim.fn.expand(ws.path)) == 1
end, obsidian_workspaces)

if #available > 0 then
	require("obsidian").setup({
		workspaces = available,
		legacy_commands = false,
		completion = {
			blink = true,
			nvim_cmp = false,
			min_chars = 1,
		},
	})
end

-- Markdown preview
vim.g.mkdp_filetypes = { "markdown" }

map("n", "<leader>rm", "<cmd>MarkdownPreview<cr>", { desc = "run MarkdownPreview" })

-- Which-key (auto-discovers keymaps; only group labels registered here)
local wk = require("which-key")
wk.setup()
wk.add({
	{ "<leader>a", group = "AI" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "check" },
	{ "<leader>d", group = "debugger" },
	{ "<leader>e", group = "errors" },
	{ "<leader>f", group = "find" },
	{ "<leader>g", group = "goto" },
	{ "<leader>i", group = "insert" },
	{ "<leader>id", group = "date" },
	{ "<leader>l", group = "lsp" },
	{ "<leader>r", group = "run" },
	{ "<leader>s", group = "settings" },
	{ "<leader>t", group = "tree view" },
	{ "<leader>T", group = "treesitter" },
	{ "<leader>v", group = "git" },
})
