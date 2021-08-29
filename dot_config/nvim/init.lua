-- vim.api.nvim_win_set_option(0, 'number', true)
vim.opt.number = true
-- vim.api.nvim_win_set_option(0, 'relativenumber', true)
vim.opt.relativenumber = true

-- vim.api.nvim_set_option('smartindent', true)
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.g.mapleader = " "

vim.api.nvim_set_keymap('n', '<Leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })

require('plugins')


