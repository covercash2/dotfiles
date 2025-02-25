-- load `lazy` packaeze manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.loop or vim.uv).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local file_tree = require("file_tree")
local keybindings = require("keybindings")
local ai = require("ai")
local json = require('json')
local spider = require("spider_move")
local nushell = require('nushell')
local test_config = require('test_config')
local typescript = require('typescript')
local ui = require('ui')

local auto_show_hover = function(bufnr)
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
			vim.diagnostic.open_float(opts)
		end,
	})
end

local recording_symbol = function()
	local register = vim.fn.reg_recording()
	if register == "" then
		return ""
	end
	return "󰑋 " .. register
end

local plugins = {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-tree/nvim-tree.lua",
			"folke/trouble.nvim",
			"nvim-neotest/neotest",
			"kazhala/close-buffers.nvim",
			"echasnovski/mini.icons",
		},
		config = function()
			local wk = require("which-key")
			wk.setup()
			wk.add(keybindings())
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
		keys = {
			{ "<leader>vB", "<cmd>GitBlameToggle<cr>", desc = "toggle git blame" },
		},
		config = function()
			require("gitblame").setup()
		end,
	},
	{
		-- auto close pairs, brackets, parentheses, quotes, etc
		"m4xshen/autoclose.nvim",
		opts = {
			keys = {
				["<"] = { escape = false, close = true, pair = "<>" },
				["'"] = { escape = true, close = false, pair = "''", disabled_filtetypes = { "rust" } },
			},
			options = {
				disable_when_touch = true,
				pair_spaces = true,
			},
		},
	},
	{
		"andrewradev/linediff.vim",
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"apple/pkl-neovim",
		},
		config = function()
			vim.cmd("TSUpdate")
			vim.treesitter.language.register("javascript", "dataviewjs")
			vim.treesitter.language.register("json", "dataviewjs")
			vim.treesitter.language.register("gotmpl", "tmpl")
      -- they're close enough, why not
			vim.treesitter.language.register("toml", "conf")
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"cpp",
					"css",
					"elm",
					"fish",
					"javascript",
					"json",
					"kotlin",
					"lua",
					"make",
					"markdown",
					"markdown_inline",
					"nu",
					"python",
					"rust",
					"svelte",
					"typescript",
				},
				highlight = {
					enable = true,
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "markdown", "html", "jsx", "svelte", "typescript" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			multiline_threshold = 8,
		},
	},
	{
		"metakirby5/codi.vim",
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		lazy = false,
		config = function()
			require("mini.ai").setup()
		end,
	},
	{ "echasnovski/mini.icons", version = false },
	{
		"echasnovski/mini.surround",
		version = "*",
		lazy = false,
		config = function()
			require("mini.surround").setup()
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
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/neodev.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"SmiteshP/nvim-navic",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local servers = {
				"biome", -- javascript stuff
				"eslint",
				"html",
				"luau_lsp",
				"lua_ls",
				"nil_ls",
        "nushell",
				"pyright",
				"ruff",
				"svelte",
				"ts_ls",
			}
			local navic = require('nvim-navic')
			local on_attach = function(client, bufnr)
				-- show a window when a doc is available
				auto_show_hover(bufnr)

				-- TODO: what is this for
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- get file navigation info
				if client.server_capabilities.documentSymbolProvider then
					navic.attach(client, bufnr)
				end
			end

      -- https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
      lspconfig.typos_lsp.setup({
        cmd_env = { RUST_LOG = "error" },
        init_options = {
          diagnositSeverity = "Error",
        }
      })

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end,
	}, -- `lspconfig`
	{
		"nvimdev/guard.nvim",
		dependencies = { "nvimdev/guard-collection" },
		config = function()
			local ft = require("guard.filetype")

			ft("python"):fmt("black"):lint("pylint")

			ft("lua"):fmt("stylua")

			ft("html,htmldjango"):fmt("djhtml"):lint({
				cmd = "djlint",
				stdin = true,
				args = { "-", "--profile=jinja" },
				parse = function(result, bufnr)
					local lint = require("guard.lint")
					local diags = {}
					local lines = vim.split(result, "\n")
					for i, line in ipairs(lines) do
						local lnum = line:match("^%u%d+%s(%d+)") -- probably wrong regex
						if lnum then
							diags[#diags + 1] =
									lint.diag_fmt(bufnr, tonumber(lnum) - 1, 0, lines[i]:gsub("\t", ""), 2, "djlint")
						end
					end
					return diags
				end,
			})

			vim.g.guard_config = {
				fmt_on_save = false,
				save_on_fmt = true,
				lsp_as_default_formatter = true,
			}
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
		"dstein64/nvim-scrollview",
		opts = {
			current_only = false,
			signs_on_startup = {
				"search",
				"diagnostics",
				"marks",
				"cursor",
				"conflicts",
				"latestchange",
			},
		},
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
		"rcarriga/nvim-notify",
		opts = {
			timeout = 1500,
		},
	},
	{
		"folke/noice.nvim",
		enabled = false,
		event = "VeryLazy",
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
			"hrsh7th/nvim-cmp",
		},
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,     -- use a classic bottom cmdline for search
				command_palette = true,   -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false,       -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false,   -- add a border to hover docs and signature help
			},
			routes = {
				-- hide `written` messages
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
				-- hide search virtual text, e.g. number found
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
					},
					opts = { skip = true },
				},
			},
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app; yarn install",
    keys = {
      {
        "<leader>rm",
        "<cmd>MarkdownPreview<cr>",
        desc = "run MarkdownPreview",
      },
    },
		ft = { "markdown" },
		cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},
	{
		"jghauser/follow-md-links.nvim",
	},
	"cespare/vim-toml",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			-- v for version/git
			{
				"<leader>vc",
				function()
					require("telescope.builtin").git_commits()
				end,
				desc = "list git commits",
			},
			{
				"<leader>vd",
				function()
					require("telescope.builtin").git_bcommits()
				end,
				desc = "list git commits for this buffer",
			},
			{
				"<leader>vb",
				function()
					require("telescope.builtin").git_branches()
				end,
				desc = "list git branches",
			},
			{
				"<leader>vs",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "list git branches",
			},

			-- f for find
			{
				"<leader>fG",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "find string in files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "search in files",
			},
			{
				"<leader>fS",
				function()
					require("telescope.builtin").spell_suggest()
				end,
				desc = "fix spelling",
			},

			-- r for run
			{
				"<leader>rc",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "list commands",
			},
			{
				"<leader>rh",
				function()
					require("telescope.builtin").command_history()
				end,
				desc = "list recent commands",
			},

			-- s for settings
			{
				"<leader>sc",
				function()
					require("telescope.builtin").colorscheme()
				end,
				desc = "list colorschemes",
			},
			{
				"<leader>sm",
				function()
					require("telescope.builtin").man_pages()
				end,
				desc = "search man pages",
			},
			{
				"<leader>so",
				function()
					require("telescope.builtin").vim_options()
				end,
				desc = "list vim options",
			},
			{
				"<leader>sq",
				function()
					require("telescope.builtin").quickfix()
				end,
				desc = "list quickfixes",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					-- defualt config here
				},
				pickers = {
					find_files = {
						-- include hidden files not in .git
						find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
					},
					commands = {
						theme = "cursor",
					},
					colorscheme = {
						theme = "dropdown",
					},
					live_grep = {
						theme = "dropdown",
					},
					spell_suggest = {
						theme = "cursor",
					},
				},
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"folke/neodev.nvim",
		},
		config = function()
			require("neodev").setup({
				library = { plugins = { "nvim-dap-ui" }, types = true },
			})
			require("dapui").setup()
		end,
	},
	{
		"nvim-telescope/telescope-dap.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("telescope").load_extension("ui-select")
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
				cmake_console_size = 10,                                                       -- cmake output window height
				cmake_show_console = "always",                                                 -- "always", "only_on_error"
				cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" }, -- dap configuration, optional
				cmake_dap_open_command = require("dap").repl.open,                             -- optional
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
		lazy = false,
		config = function()
			vim.cmd.colorscheme("kanagawa")
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		-- lazy = false,
		-- config = function()
		-- 	vim.cmd.colorscheme("kanagawa")
		-- end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lualine").setup({
				theme = "auto",
				sections = {
					lualine_c = {
						function()
							return vim.api.nvim_buf_get_name(0)
						end,
					},
					lualine_x = {
						recording_symbol,
					},
				},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	file_tree.lazy,
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
		"mrcjkb/rustaceanvim",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		version = "^5",
		ft = { "rust" },
		lazy = false,
		config = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufnr)
						auto_show_hover(bufnr)
					end,
					default_settings = {
						['rust-analyzer'] = {
							cargo = {
								features = "all",
							},
						},
					},
				},
			}
			-- https://github.com/helix-editor/helix/wiki/Debugger-Configurations#install-debuggers
			local dap = require("dap")
			local path = vim.fn.executable("lldb-dap")
			if path == nil then
				vim.print("could not find path to lldb-dap")
			else
				dap.adapters.lldb = {
					type = "executable",
					command = path,
					name = "lldb",
				}
				dap.configurations.rust = {
					initCommands = function()
						local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

						local script_import = 'command script import "'
								.. rustc_sysroot
								.. "lib/rustlib/etc/lldb_lookup.py"
						local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

						local commands = {}
						local file = io.open(commands_file, "r")
						if file then
							for line in file:lines() do
								table.insert(commands, line)
							end
							file:close()
						end
						table.insert(commands, 1, script_import)

						return commands
					end,
					env = function()
						local variables = {}
						for k, v in pairs(vim.fn.environ()) do
							table.insert(variables, string.format("%s=%s", k, v))
						end
						return variables
					end,
				}
			end
		end,
	},
	{
		"ryo33/nvim-cmp-rust",
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			local compare = require("cmp.config.compare")
			local cmp_rust = require("cmp-rust")
			require("cmp").setup.filetype({ "rust" }, {
				sorting = {
					priority_weight = 2,
					comparators = {
						cmp_rust.deprioritize_postfix,
						cmp_rust.deprioritize_borrow,
						cmp_rust.deprioritize_deref,
						cmp_rust.deprioritize_common_traits,
						compare.offset,
						compare.exact,
						compare.score,
						compare.recently_used,
						compare.locality,
						compare.sort_text,
						compare.length,
						compare.order,
					},
				},
			})
		end,
	},
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
		},
		event = {
			"BufReadPre " .. vim.fn.expand("~") .. "/obsidian/**.md",
			"BufNewFile " .. vim.fn.expand("~") .. "/obsidian/**.md",
		},
		opts = {
			workspaces = {
				{
					name = "core",
					path = "~/obsidian/core",
				},
				{
					name = "work",
					path = "~/obsidian/work",
				},
				{
					name = "DnD",
					path = "~/obsidian/DnD/",
				},
			},
		},
		completion = {
			nvim_cmp = true,
			min_chars = 1,
		},
	},
	ai.spec,
	json.jsonpath,
	json.jq_playground,
	spider.spec,
	test_config.neotest,
	-- nushell.spec,
	require("oil_config").spec,
	typescript.dap,
	typescript.debug,
	typescript.neotest,
	ui.winbar,
}

require("lazy").setup({
	spec = plugins,
	install = { colorscheme = { "kanagawa" } },
	checker = { enabled = false },
})
