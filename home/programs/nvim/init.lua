-- Options and keymaps must load before plugins (leader key, etc.)
require("config.options")
require("config.keymaps")

local gh = "https://github.com/"
local gl = "https://gitlab.com/"

vim.pack.add({
	-- Core dependencies
	gh .. "nvim-lua/plenary.nvim",
	gh .. "MunifTanjim/nui.nvim",
	gh .. "stevearc/dressing.nvim",
	gh .. "folke/snacks.nvim",
	gh .. "nvim-tree/nvim-web-devicons",
	gh .. "nvim-mini/mini.icons",

	-- LSP
	gh .. "neovim/nvim-lspconfig",
	gh .. "SmiteshP/nvim-navic",
	gh .. "b0o/schemastore.nvim",

	-- Completion
	{ src = gh .. "saghen/blink.cmp", version = vim.version.range(">=1.0.0 <2.0.0") },
	gh .. "rafamadriz/friendly-snippets",
	{ src = gh .. "saghen/blink.compat", version = vim.version.range(">=2.0.0 <3.0.0") },

	-- AI
	gh .. "zbirenbaum/copilot.lua",
	gh .. "ravitemer/mcphub.nvim",
	gh .. "yetone/avante.nvim",
	gh .. "HakonHarnes/img-clip.nvim",
	gh .. "meanderingProgrammer/render-markdown.nvim",

	-- DAP
	gh .. "mfussenegger/nvim-dap",
	gh .. "rcarriga/nvim-dap-ui",
	gh .. "nvim-neotest/nvim-nio",
	gh .. "mxsdev/nvim-dap-vscode-js",
	gh .. "microsoft/vscode-js-debug",

	-- Navigation / search
	{ src = gh .. "nvim-telescope/telescope.nvim", version = "0.1.4" },
	gh .. "nvim-telescope/telescope-dap.nvim",
	gh .. "nvim-telescope/telescope-ui-select.nvim",
	gh .. "folke/flash.nvim",
	gh .. "chrisgrieser/nvim-spider",
	gh .. "stevearc/oil.nvim",

	-- Editor
	gh .. "nvim-mini/mini.ai",
	gh .. "nvim-mini/mini.surround",
	gh .. "nvim-mini/mini.indentscope",
	gh .. "nvim-mini/mini.trailspace",
	gh .. "nvim-mini/mini.comment",
	gh .. "m4xshen/autoclose.nvim",
	gh .. "andrewradev/linediff.vim",
	gh .. "metakirby5/codi.vim",
	gh .. "numToStr/Comment.nvim",
	gh .. "folke/todo-comments.nvim",
	gh .. "kazhala/close-buffers.nvim",
	gh .. "vuciv/golf",

	-- Git
	gh .. "tpope/vim-fugitive",
	gh .. "f-person/git-blame.nvim",
	gh .. "lewis6991/gitsigns.nvim",
	gh .. "akinsho/git-conflict.nvim",
	gh .. "almo7aya/openingh.nvim",

	-- Formatting / linting
	gh .. "nvimdev/guard.nvim",
	gh .. "nvimdev/guard-collection",

	-- Testing
	gh .. "nvim-neotest/neotest",
	gh .. "nvim-neotest/neotest-jest",
	gh .. "marilari88/neotest-vitest",
	gh .. "andythigpen/nvim-coverage",
	gh .. "antoinemadec/FixCursorHold.nvim",

	-- Treesitter
	gh .. "nvim-treesitter/nvim-treesitter",
	gh .. "nvim-treesitter/nvim-treesitter-context",
	gh .. "windwp/nvim-ts-autotag",
	gh .. "apple/pkl-neovim",
	{ src = gl .. "HiPhish/rainbow-delimiters.nvim.git" },

	-- UI
	gh .. "nvim-lualine/lualine.nvim",
	{ src = gh .. "nvim-neo-tree/neo-tree.nvim", version = "v3.x" },
	gh .. "fgheng/winbar.nvim",
	gh .. "folke/which-key.nvim",
	gh .. "dstein64/nvim-scrollview",
	gh .. "folke/trouble.nvim",
	gh .. "rcarriga/nvim-notify",
	{ src = gh .. "j-hui/fidget.nvim", version = "legacy" },
	{ src = gh .. "s1n7ax/nvim-window-picker", name = "window-picker", version = vim.version.range(">=2.0.0 <3.0.0") },

	-- Language-specific
	{ src = gh .. "mrcjkb/rustaceanvim", version = vim.version.range(">=8.0.0 <9.0.0") },
	gh .. "p00f/clangd_extensions.nvim",
	gh .. "Civitasv/cmake-tools.nvim",
	gh .. "phelipetls/jsonpath.nvim",
	gh .. "yochem/jq-playground.nvim",

	-- Markdown / notes
	gh .. "iamcco/markdown-preview.nvim",
	gh .. "jghauser/follow-md-links.nvim",
	gh .. "obsidian-nvim/obsidian.nvim",

	-- Themes
	{ src = gh .. "bluz71/vim-nightfly-colors", name = "nightfly" },
	{ src = gh .. "catppuccin/nvim", name = "catppuccin" },
	gh .. "rebelot/kanagawa.nvim",

	-- Misc
	gh .. "oysandvik94/curl.nvim",
})

-- Build hooks: run build commands when plugins are installed or updated.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.kind == "delete" then
			return
		end

		local name = ev.data.spec.name
		local path = ev.data.path

		-- Shell build commands (run async in the plugin directory)
		local shell_builds = {
			["blink.cmp"] = "cargo build --release",
			["avante.nvim"] = "make",
			["markdown-preview.nvim"] = "cd app && yarn install",
			["vscode-js-debug"] = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
		}

		local cmd = shell_builds[name]
		if cmd then
			vim.notify("Building " .. name .. "...", vim.log.levels.INFO)
			vim.fn.jobstart(cmd, {
				cwd = path,
				on_exit = function(_, code)
					if code == 0 then
						vim.schedule(function()
							vim.notify(name .. " built successfully", vim.log.levels.INFO)
						end)
					else
						vim.schedule(function()
							vim.notify(name .. " build failed (exit " .. code .. ")", vim.log.levels.ERROR)
						end)
					end
				end,
			})
		end

		-- Vim command builds
		if name == "mason.nvim" then
			vim.schedule(function()
				vim.cmd("MasonUpdate")
			end)
		end

		-- Lua script builds
		if name == "mcphub.nvim" then
			dofile(path .. "/bundled_build.lua")
		end
	end,
})
