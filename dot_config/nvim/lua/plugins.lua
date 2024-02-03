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

local rust_config = require("rust")
local file_tree = require("file_tree")
local keybindings = require("keybindings")

local plugins = {
	{
		"folke/which-key.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-tree/nvim-tree.lua",
			"folke/trouble.nvim",
			"nvim-neotest/neotest",
			"ThePrimeagen/harpoon",
		},
		config = function()
			local wk = require("which-key")
			wk.setup()
			wk.register(keybindings(), { prefix = "<leader>" })
		end,
	},
	{
		url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			require("rainbow-delimiters.setup").setup({
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				priority = {
					[""] = 110,
					lua = 210,
				},
				highlight = {
					"RainbowDelimiterGreen",
					"RainbowDelimiterCyan",
					"RainbowDelimiterBlue",
					"RainbowDelimiterViolet",
					"RainbowDelimiterGreen",
					"RainbowDelimiterCyan",
					"RainbowDelimiterBlue",
					"RainbowDelimiterViolet",
					"RainbowDelimiterYellow",
					"RainbowDelimiterOrange",
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterOrange",
					"RainbowDelimiterRed",
				},
			})
		end,
	},
	"tpope/vim-fugitive",
	{
		"f-person/git-blame.nvim",
		config = function()
			require("gitblame").setup()
		end,
	},
	{
		"nvim-neorg/neorg",
		ft = "norg",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {},
					["core.norg.concealer"] = {},
					["core.norg.completion"] = {
						config = {
							engine = "nvim-cmp",
						},
					},
					["core.norg.dirman"] = {
						config = {
							workspaces = {
								work = "~/personal",
								home = "~/Notes",
							},
						},
					},
				},
			})
			vim.cmd("Neorg sync-parsers")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			vim.cmd("TSUpdate")
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"rust",
					"kotlin",
					"python",
					"elm",
					"cpp",
					"cmake",
					"bash",
					"fish",
					"make",
					"markdown",
					"norg",
					"kdl",
					"svelte",
					"javascript",
					"typescript",
					"tsx",
					"json",
					"css",
				},
				highlight = {
					enable = false,
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = {
			multiline_threshold = 8,
		},
	},
	{
		"metakirby5/codi.vim",
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		lazy = false,
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		lazy = false,
		config = function()
			require("mini.surround").setup()
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
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
		end,
	},
	-- snippet
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
	-- autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"neovim/nvim-lspconfig",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			vim.o.completeopt = "menu,menuone,noselect"
			local cmp = require("cmp")
			cmp.setup({
				view = {
					entries = "custom",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer", keyword_length = 3 },
				}),
				mapping = {
					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete()),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				},
				enabled = true,
				autocomplete = true,
				norg = true,
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		dependencies = { "neovim/nvim-lspconfig", "williamboman/mason-lspconfig.nvim" },
		lazy = false,
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/nvim-lsp-installer",
		config = function()
			require("nvim-lsp-installer").setup({})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/neodev.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"williamboman/nvim-lsp-installer",
		},
		config = function()
			local nvim_lsp = require("lspconfig")
			local servers = { "pyright", "luau_lsp", "lua_ls", "svelte", "tsserver", "rust_analyzer", "eslint" }
			local on_attach = function(client, bufnr)
				vim.o.updatetime = 250

				-- show a window when a doc is available
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						local opts = {
							focusable = false,
							close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
							border = "rounded",
							source = "always",
							prefix = " ",
							scope = "cursor",
						}
						vim.diagnostic.open_float(nil, opts)
					end,
				})

				local function buf_set_keymap(...)
					vim.api.nvim_buf_set_keymap(bufnr, ...)
				end
				local function buf_set_option(...)
					vim.api.nvim_buf_set_option(bufnr, ...)
				end

				buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

				local opts = { noremap = true, silent = true }

				buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
				buf_set_keymap(
					"n",
					"<leader>wl",
					"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
					opts
				)
				buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
				buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			for _, server in ipairs(servers) do
				nvim_lsp[server].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end,
	}, -- lspconfig
	{
		"nvimdev/guard.nvim",
		dependencies = { "nvimdev/guard-collection" },
		config = function()
			local ft = require("guard.filetype")

			ft("python"):fmt("black"):lint("pylint")

			ft("lua"):fmt("stylua")

			ft("*"):lint("codespell")

			require("guard").setup({
				fmt_on_save = true,
				lsp_as_default_formatter = true,
			})
		end,
	},
	-- svelte
	{
		"leafOfTree/vim-svelte-plugin",
		config = function()
			vim.g.vim_svelte_plugin_load_full_syntax = 1
			vim.g.vim_svelte_plugin_use_typescript = 1
		end,
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		config = true,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"preservim/vim-markdown",
		dependencies = { "godlygeek/tabular" },
	},
	{
		"folke/trouble.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"folke/neodev.nvim",
		opts = {},
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && yarn install",
		--cmd = 'MarkdownPreview'
	},
	"cespare/vim-toml",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"ThePrimeagen/harpoon",
		},
		config = function()
			require("telescope").setup({
				pickers = {
					find_files = {
						-- include hidden files not in .git
						find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
					},
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope-dap.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("telescope").load_extension("dap")
		end,
	},
	{
		"akinsho/git-conflict.nvim",
		config = function()
			require("git-conflict").setup()
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("clangd_extensions").setup()
		end,
	},
	{
		"Civitasv/cmake-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("cmake-tools").setup({
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
					long = { show = true, max_length = 40 },
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({
				default = true,
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				git = {
					ignore = false,
				},
			})
		end,
	},
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppucin",
		priority = 1000,
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("kanagawa")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = {
			theme = "auto",
		},
	},
	{
		"LhKipp/nvim-nu",
		config = function()
			require("nu").setup({
				use_lsp_features = false,
			})
		end,
	},
	file_tree.lazy,
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-jest",
			"rouge8/neotest-rust",
		},
		config = function()
			require("neotest").setup({
				discovery = {
					enabled = false,
				},
				adapters = {
					require("neotest-jest")({
						jest_command = "pnpm test --",
						jestConfigFile = function()
							local file = vim.fn.expand("%:p")
							if string.find(file, "/packages/") then
								local match = string.match(file, "(.-/[^/]+/)src") .. "jest.config.js"
								print("using config: ", match)
								if vim.fn.filereadable(match) then
									return match
								else
									print("file did not match expected: ", match)
								end
							end

							local baseconfig = vim.fn.getcwd() .. "/jest.config.base.js"

							print("using base config: " .. baseconfig)

							if vim.fn.filereadable(baseconfig) then
								return baseconfig
							else
								print("could not find base config at: ", baseconfig)
							end
						end,
						env = { CI = true },
						cwd = function(path)
							return vim.fn.getcwd()
						end,
						jest_test_discovery = true,
					}),
					require('neotest-rust') {
						dap_adapter = "lldb",
					},
				},
			})
		end,
	},
	{
		"andythigpen/nvim-coverage",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local get_lcov_file = function()
				local file = vim.fn.expand("%:p")
				if string.find(file, "/packages/") then
					local match = string.match(file, "(.-/[^/]+/)coverage") .. "lcov.info"
					print("using coverage report: ", match)
					if vim.fn.filereadable(match) then
						return match
					else
						print("file did not match expected: ", match)
					end
				end
				print("no coverage file found")
			end

			require("coverage").setup({
				lcov_file = get_lcov_file,
			})
		end,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("dap-vscode-js").setup({
				adapters = { "pwa-node" },
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
			})
		end,
	},
	{
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps; npx gulp vsDebugServerBundle; mv dist out",
	},
	--rust,
}

require("lazy").setup(plugins)
