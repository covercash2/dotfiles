-- set leader key to space.
-- this needs to be done before `lazy` is loaded
vim.g.mapleader = " "

-- vim.o.number = true
vim.o.relativenumber = true

vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 10

vim.o.clipboard = "unnamedplus"

vim.o.updatetime = 150

vim.o.breakindent = true

require("config.lazy")
