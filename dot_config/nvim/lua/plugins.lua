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
		config = function()
			local nvim_lsp = require('lspconfig')
			local servers = { "rust_analyzer" }
			for _, server in ipairs(servers) do
				nvim_lsp[server].setup{}
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
							formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --column-limit=100 --break-after-table-lb",
							formatStdin = true,
						},
					}
				},
			}
		end
	}
	-- bottom bar config
	use {
		'vim-airline/vim-airline',
		config = function()
			vim.g.airline_powerline_fonts = 1
		end
	}
	use 'vim-airline/vim-airline-themes'
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
end)

