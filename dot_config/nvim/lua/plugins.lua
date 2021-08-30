vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use {
		'vhyrro/neorg',
		requires = 'nvim-lua/plenary.nvim',
		config = function()
			require('neorg').setup {
				load = {
					['core.defaults'] = {},
					['core.keybinds'] = {
						config = {
							default_keybinds = true,
							neorg_leader = "<Leader>o"
						}
					},
					['core.norg.concealer'] = {}, -- icons
					['core.norg.dirman'] = {
						config = {
							workspaces = {
								my_workspace = "~/Notes"
							}
						}
					}
				}
			}
		end
	}

	use 'tpope/vim-surround'
	-- autocomplete for org mode
	use {
		'hrsh7th/nvim-compe',
		config = function()
			vim.o.completeopt = "menuone,noselect"
			require('compe').setup {
				enabled = true;
				autocomplete = true;
				norg = true;
			}
		end
	}
	use {
		'neovim/nvim-lspconfig',
		requires  = 'nvim-lua/completion-nvim',
		config = function()
			local nvim_lsp = require('lspconfig')
			local servers = { "rust_analyzer", "pyright" }
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
				buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
				buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
				buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
				buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
				buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
				buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
				buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
				buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
				buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
				buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
				buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
				buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)


				require('completion').on_attach()
			end
			for _, server in ipairs(servers) do
				nvim_lsp[server].setup{
					on_attach = on_attach,
					capabilities = capabilities
				}
			end
			local sumneko_root = vim.fn.expand("$HOME") .. "/.config/nvim/lua-language-server"
			local os_string = ""
			if vim.fn.has("mac") == 1 then
				os_string = "macOS"
			elseif vim.fn.has("unix") == 1 then
				os_string = "Linux"
			else
			    print("Unsupported OS detected")
			end
			local sumneko_binary = sumneko_root .. "/bin/" .. os_string .. "/lua-language-server"
			local runtime_path = vim.split(package.path, ";")

			table.insert(runtime_path, 'lua/?.lua')
			table.insert(runtime_path, 'lua/?/init.lua')
			nvim_lsp.sumneko_lua.setup {
				cmd = { sumneko_binary, "-E", sumneko_root .. "/main.lua" },
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
							path = runtime_path,
						},
						diagnostics = {
							globals = {'vim'}
						},
						workspace = {
							library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
							--library = vim.api.nvim_get_runtime_file('', true)
						},
					}
				}
			}
			require('lspconfig').efm.setup {
				init_options = {documentFormatting = true},
				filetypes = {"lua"},
				settings = {
					rootMarkers = {".git/"},
					languages = {
						lua = {
							formatCommand = "lua-format -i " ..
							"--no-keep-simple-function-one-line" ..
							"--no-break-after-operator" ..
							"--column-limit=100" ..
							"--break-after-table-lb",
							formatStdin = true,
						},
					}
				},
			}
		end
	} -- lsp-config
	-- bottom bar config
	use {
		'hoob3rt/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons', opt = true},
		config = {
			require('lualine').setup {
				options = {theme = 'ayu_mirage'}
			}
		}
	}
	use 'airblade/vim-gitgutter'
	use {
		-- embed nvim in the browser
		'glacambre/firenvim',
		run = function() vim.fn['firenvim#install'](0) end
	}
	use {
		'plasticboy/vim-markdown',
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
end)

