vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	-- markdown editor
	use {"ellisonleao/glow.nvim"}

	use {
		'folke/which-key.nvim',
		requires = { 'nvim-telescope/telescope.nvim' },
		config = function() 
			local wk = require('which-key')
			wk.setup()
			local telescope = require('telescope.builtin')
			wk.register({
				f = {
					name = "file",
					f = { telescope.find_files, "find file" },
					g = { telescope.live_grep, "grep" },
					b = { telescope.buffers, "find buffer" },
					h = { telescope.help_tags, "help tags" },
				},
			}, { prefix = '<leader>' })
		end
	}
	use 'sbdchd/neoformat'

	use {
		"nvim-neorg/neorg",
		requires = { 
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {},
					["core.norg.concealer"] = {},
					["core.norg.completion"] = {
						config = {
							engine = "nvim-cmp"
						}
					},
					["core.norg.dirman"] = {
						config = {
							workspaces = {
								work = "~/Notes",
								home = "~/Notes",
							}
						}
					}
				}
			}
		end
	}

	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = {"rust", "python", "norg", "cpp", "cmake", "bash", "fish", "make", "markdown"},
				highlight = {
					enable = true
				}
			}
		end
	}

	use 'tpope/vim-surround'
	-- autocomplete for org mode
	use {
		'hrsh7th/nvim-cmp',
		requires = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip',
		},
		config = function()
			vim.o.completeopt = "menu,menuone,noselect"
			local cmp = require('cmp')
			cmp.setup {
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'vsnip' },
				}, { { name = 'buffer' } });
				mapping = {
					['<C-Space'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				};
				enabled = true;
				autocomplete = true;
				norg = true;
			}
		end
	}
	use {
		'neovim/nvim-lspconfig',
		requires  = {
			'nvim-lua/completion-nvim'
		},
		config = function()
			local nvim_lsp = require('lspconfig')
			local servers = { "rust_analyzer", "pyright", "luau_lsp" }
			local on_attach = function(client, bufnr)
				local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
				local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

				buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

				local opts = { noremap=true, silent=true }

				buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
				buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
				buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
				buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
				buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
				buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
				buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
				buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
				buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
				buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
				buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
				buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
				buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
				buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
				buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
				buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
				buf_set_keymap('n', '<leader>bf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

				require('completion').on_attach()
			end
			for _, server in ipairs(servers) do
				nvim_lsp[server].setup{
					on_attach = on_attach,
					capabilities = capabilities
				}
			end
		end
	} -- lsp-config

	-- bottom bar config
	use {
		'hoob3rt/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons', opt = true},
		config = function()
			require('lualine').setup {
				options = {theme = 'ayu_mirage'}
			}
		end
	}

	use { 
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	}

	use {
		-- embed nvim in the browser
		'glacambre/firenvim',
		run = function() vim.fn['firenvim#install'](0) end
	}
	use {
		'preservim/vim-markdown',
		requires = 'godlygeek/tabular'
	}
	use 'jiangmiao/auto-pairs'
	use 'joshdick/onedark.vim'
	use 'folke/tokyonight.nvim'
	use {
		'iamcco/markdown-preview.nvim',
		run = 'cd app && yarn install',
		--cmd = 'MarkdownPreview'
	}
	use 'cespare/vim-toml'
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use {
		'akinsho/git-conflict.nvim',
		config = function()
			require('git-conflict').setup()
		end
	}

	use {
		'p00f/clangd_extensions.nvim',
		requires = 'neovim/nvim-lspconfig',
		config = function()
			require('clangd_extensions').setup()
		end
	}

end)

