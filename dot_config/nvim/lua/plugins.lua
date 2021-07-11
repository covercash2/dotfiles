vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use {
		'kristijanhusak/orgmode.nvim',
		config = function()
			require('orgmode').setup {
				org_agenda_files = { '~/system/Sync/notes/*'}
			}
		end
	}
	use 'tpope/vim-surround'
	-- autocomplete for org mode
	use { 
		'hrsh7th/nvim-compe',
		config = function()
			require('compe').setup {
				orgmode = true
			}
		end
	}
end)
