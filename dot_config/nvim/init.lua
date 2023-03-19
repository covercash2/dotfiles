-- vim.api.nvim_win_set_option(0, 'number', true)
vim.opt.number = true
-- vim.api.nvim_win_set_option(0, 'relativenumber', true)
vim.opt.relativenumber = true

-- vim.api.nvim_set_option('smartindent', true)
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- https://github.com/nvim-tree/nvim-tree.lua#setup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable highlight groups
vim.opt.termguicolors = true

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require('plugins')

vim.api.nvim_create_autocmd(
	"InsertLeave",
	{
		pattern = "*",
		command = [[silent! update]],
	})

vim.g.mapleader = " "

