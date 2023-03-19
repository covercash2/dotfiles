-- load `lazy` package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
	{
		'folke/which-key.nvim',
		dependencies = {
			'nvim-telescope/telescope.nvim',
			'nvim-tree/nvim-tree.lua',
		},
		config = function()
			local wk = require('which-key')
			wk.setup()
			local telescope = require('telescope.builtin')
			local tree = require('nvim-tree.api')
			wk.register({
				f = {
					name = "file",
					f = { telescope.find_files, "find file" },
					g = { telescope.live_grep, "grep" },
					b = { telescope.buffers, "find buffer" },
					h = { telescope.help_tags, "help tags" },
				},
				t = {
					name = "tree",
					t = { tree.tree.toggle, "toggle" },
				}
			}, { prefix = '<leader>' })
		end
	},
	"sbdchd/neoformat",
	{
		"nvim-neorg/neorg",
		ft = "norg",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
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
								work = "~/personal",
								home = "~/Notes",
							}
						}
					}
				}
			}
			vim.cmd("Neorg sync-parsers")
		end
	},
	{
		'nvim-treesitter/nvim-treesitter',
		config = function()
			vim.cmd('TSUpdate')
			require('nvim-treesitter.configs').setup {
				ensure_installed = {"lua", "rust", "python", "elm", "cpp", "cmake", "bash", "fish", "make", "markdown", "norg", "kdl"},
				highlight = {
					enable = false
				}
			}
		end
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		lazy = false,
		config = function()
			require('mini.ai').setup()
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		lazy = false,
		config = function()
			require('mini.surround').setup()
		end,
	},
	{
		"echasnovski/mini.pairs",
		version = "*",
		lazy = false,
		config = function()
			require("mini.pairs").setup()
		end,
	},
	{
		"echasnovski/mini.indentscope",
		version = "*",
		lazy = false,
		config = function()
			require("mini.indentscope").setup()
		end,
	},
	{
		"echasnovski/mini.trailspace",
		version = "*",
		lazy = false,
		config = function()
			require("mini.trailspace").setup()
		end,
	},
	{
		"echasnovski/mini.comment",
		version = "*",
		lazy = false,
		config = function()
			require("mini.comment").setup()
		end,
	},
	-- autocomplete for org mode
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
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
	},
	{
		'williamboman/mason.nvim',
		dependencies = { "neovim/nvim-lspconfig", "williamboman/mason-lspconfig.nvim"},
		lazy = false,
		config = function()
			require("mason").setup {
				ensure_installed = { "lua_ls", "pyright", "elmls" }
			}
		end
	},
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'nvim-lua/completion-nvim'
		},
		config = function()
			local nvim_lsp = require('lspconfig')
			local servers = { "pyright", "luau_lsp" }
			local on_attach = function(client, bufnr)
				vim.o.updatetime = 250

				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						local opts = {
							focusable = false,
							close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
							border = 'rounded',
							source = 'always',
							prefix = ' ',
							scope = 'cursor',
						}
						vim.diagnostic.open_float(nil, opts)
					end
				})

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
				buf_set_keymap('n', '<leader>bf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)

				require('completion').on_attach()
			end
			for _, server in ipairs(servers) do
				nvim_lsp[server].setup{
					on_attach = on_attach,
					capabilities = capabilities
				}
			end
		end
	}, -- lspconfig
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.diagnostics.eslint,
					null_ls.builtins.completion.spell,
				}
			})
		end,
	},
	{
		"tamago324/nlsp-settings.nvim",
		dependencies = { "neovim/nvim-lspconfig", "williamboman/nvim-lsp-installer" },
		config = function()
			local lsp_installer = require("nvim-lsp-installer")
			local lspconfig = require("lspconfig")
			local nlspsettings = require("nlspsettings")

			nlspsettings.setup({
				config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
				local_settings_dir = ".nlsp-settings",
				local_settings_root_markers_fallback = { ".git" },
				append_default_schemas = true,
				loader = "json",
			})
			function on_attach(client, buf_num)
				local function buf_set_option(...) vim.api.nvim_buf_set_option(buf_num, ...) end
				buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
			end

			local global_capabilities = vim.lsp.protocol.make_client_capabilities()
			global_capabilities.textDocument.completion.completionItem.snippetSupport = true

			lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
				capabilities = global_capabilities,
			})

			lsp_installer.on_server_ready(function(server)
				server:setup({
					on_attach = on_attach
				})
			end)

		end
	},
	{
		"j-hui/fidget.nvim",
		config = true,
	},
	-- bottom bar config
	{
		'hoob3rt/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', opt = true},
		config = function()
			require('lualine').setup {
				options = {theme = 'ayu_mirage'}
			}
		end
	},
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	},
	{
		-- embed nvim in the browser
		'glacambre/firenvim',
		cond = not not vim.g.started_by_firenvim,
		build = function()
			require("lazy").load({ plugins = "firenvim", wait = true})
			vim.fn['firenvim#install'](0)
		end,
	},
	{
		'preservim/vim-markdown',
		dependencies = { 'godlygeek/tabular' },
	},
	{
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd[[colorscheme tokyonight]]
		end,
	},
	{
		'iamcco/markdown-preview.nvim',
		build = 'cd app && yarn install',
		--cmd = 'MarkdownPreview'
	},
	'cespare/vim-toml',
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		'akinsho/git-conflict.nvim',
		config = function()
			require('git-conflict').setup()
		end
	},
	{
		'p00f/clangd_extensions.nvim',
		dependencies = { 'neovim/nvim-lspconfig' },
		config = function()
			require('clangd_extensions').setup()
		end
	},
	{
		'Civitasv/cmake-tools.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'mfussenegger/nvim-dap',
		},
		config = function()
			require('cmake-tools').setup {
				cmake_command = "cmake",
				cmake_build_directory = "build",
				cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
				cmake_build_options = {},
				cmake_console_size = 10, -- cmake output window height
				cmake_show_console = "always", -- "always", "only_on_error"
				cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" }, -- dap configuration, optional
				cmake_dap_open_command = require("dap").repl.open, -- optional
				cmake_variants_message = {
				  short = { show = true },
				  long = { show = true, max_length = 40 }
				}
			}
		end
	},
	{
		'nvim-tree/nvim-web-devicons',
		config = function()
			require('nvim-web-devicons').setup {
				default = true
			}
		end
	},
	{
		'nvim-tree/nvim-tree.lua',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},
		config = function()
			require('nvim-tree').setup {
				git = {
					ignore = false,
				}
			}
		end
	},
	{
		'simrat39/rust-tools.nvim',
		dependencies = {
			"nvim-lspconfig",
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			rt = require('rust-tools')
			rt.setup({
				server = {
					on_attach = function(_, bufnr)
						-- code action groups
						vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
						-- hover action
						vim.keymap.set("n", "<Leader><Leader>", rt.hover_actions.hover_actions, { buffer = bufnr })
					end
				}
			})

			local lsp_installer = require("nvim-lsp-installer")
			local lspconfig = require("lspconfig")
			local nlspsettings = require("nlspsettings")

			nlspsettings.setup({
				config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
				local_settings_dir = ".nlsp-settings",
				local_settings_root_markers_fallback = { ".git" },
				append_default_schemas = true,
				loader = "json",
			})
			function on_attach(client, buf_num)
				local function buf_set_option(...) vim.api.nvim_buf_set_option(buf_num, ...) end
				buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
			end

			local global_capabilities = vim.lsp.protocol.make_client_capabilities()
			global_capabilities.textDocument.completion.completionItem.snippetSupport = true

			lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
				capabilities = global_capabilities,
			})

			lsp_installer.on_server_ready(function(server)
				server:setup({
					on_attach = on_attach
				})
			end)


		end
	}
}

require("lazy").setup(plugins)
