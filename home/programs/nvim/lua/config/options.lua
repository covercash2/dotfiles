vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.relativenumber = true
vim.o.number = true

vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 10
vim.opt.wrap = true

-- use rg for vimgrep
-- https://neovim.io/doc/user/quickfix/
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.o.clipboard = "unnamedplus"

vim.o.updatetime = 150

vim.o.breakindent = true

vim.o.exrc = true
