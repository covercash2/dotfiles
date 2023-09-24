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

local plugins = {
	{
		"folke/which-key.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-tree.lua",
			"folke/trouble.nvim",
		},
		config = function()
			local wk = require("which-key")
			wk.setup()
			local telescope = require("telescope.builtin")
			wk.register({
				a = { vim.lsp.buf.code_action, "code action" },
				b = {
					name = "buffer",
					f = { vim.lsp.buf.format, "format" },
				},
				D = { vim.lsp.buf.type_definition, "type definition" },
				e = {
					name = "errors",
					l = {
						vim.lsp.diagnostic.get_line_diagnostics,
						"line diagnostics",
					},
					t = {
						function()
							vim.cmd([[TroubleToggle]])
						end,
						"trouble",
					},
				},
				f = {
					name = "file",
					f = { telescope.find_files, "find file" },
					g = { telescope.live_grep, "grep" },
					b = { telescope.buffers, "find buffer" },
					h = { telescope.help_tags, "help tags" },
				},
				g = {
					name = "goto",
					d = { vim.lsp.buf.definition, "definition" },
					D = { vim.lsp.buf.declration, "declaration" },
					i = { vim.lsp.buf.implementation, "implementation" },
					r = { vim.lsp.buf.references, "references" },
					p = { vim.lsp.diagnostic.goto_prev, "previous" },
					n = { vim.lsp.buf.format, "format" },
				},
				r = { vim.lsp.buf.rename, "rename" },
				t = {
					name = "tree",
					t = { file_tree.show, "toggle" },
					b = { file_tree.buffers, "buffers" },
					g = { file_tree.git, "git status" },
				},
			}, { prefix = "<leader>" })
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"HiPhish/nvim-ts-rainbow2",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				rainbow = {
					enable = true,
					query = "rainbow-parens",
					strategy = require("ts-rainbow").strategy.global,
				},
			})
		end,
	},
	"tpope/vim-fugitive",
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
		"echasnovski/mini.ai",
		version = "*",
		lazy = false,
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"echasnovski/mini.statusline",
		version = "*",
		config = function()
			require("mini.statusline").setup()
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
	-- snippet
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
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
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand()
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lua" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer", keyword_length = 3 },
				}),
				mapping = {
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space"] = cmp.mapping(cmp.mapping.complete()),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				},
				enabled = true,
				autocomplete = true,
				norg = true,
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
			require("nvim-lsp-installer").setup {}
		end

	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"williamboman/nvim-lsp-installer",
		},
		config = function()
			local nvim_lsp = require("lspconfig")
			local servers = { "pyright", "luau_lsp", "svelte", "tsserver", "rust_analyzer", "eslint" }
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
				buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
				buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
				buf_set_keymap(
					"n",
					"<leader>wl",
					"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
					opts
				)
				buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
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
		dependencies = { "nvimdev/guard-collection"},
		config = function()
			local ft = require('guard.filetype')

			ft('python'):fmt('black')
				:lint('pylint')

			require('guard').setup({
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
		"leafgarland/typescript-vim",
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
		-- embed nvim in the browser
		"glacambre/firenvim",
		cond = not not vim.g.started_by_firenvim,
		build = function()
			require("lazy").load({ plugins = "firenvim", wait = true })
			vim.fn["firenvim#install"](0)
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
		"iamcco/markdown-preview.nvim",
		build = "cd app && yarn install",
		--cmd = 'MarkdownPreview'
	},
	"cespare/vim-toml",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		dependencies = { "nvim-lua/plenary.nvim" },
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
		config = function()
			vim.cmd([[colorscheme nightfly]])
		end,
	},
	file_tree.lazy,
	--rust,
}

require("lazy").setup(plugins)
