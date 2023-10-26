vim.o.number = true
--vim.o.relativenumber = true

-- vim.api.nvim_set_option('smartindent', true)
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.o.clipboard = 'unnamedplus'

-- https://github.com/nvim-tree/nvim-tree.lua#setup
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable highlight groups
vim.opt.termguicolors = true

require('plugins')

vim.api.nvim_create_autocmd(
	"InsertLeave",
	{
		pattern = "*",
		command = [[silent! update]],
	})

-- set leader key to space
vim.g.mapleader = " "

