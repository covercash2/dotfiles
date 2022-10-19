-- vim.api.nvim_win_set_option(0, 'number', true)
vim.opt.number = true
-- vim.api.nvim_win_set_option(0, 'relativenumber', true)
vim.opt.relativenumber = true

-- vim.api.nvim_set_option('smartindent', true)
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require('plugins')

vim.g.mapleader = " "

local opts = { noremap=true, silent=true }

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, opts)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts)
vim.keymap.set('n', '<leader>fb', builtin.buffers, opts)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, opts)


vim.cmd[[colorscheme onedark]]

