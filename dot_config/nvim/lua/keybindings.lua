local harpoon_telescope_config = function()
	local harpoon = require("harpoon")
	local telescope = require("telescope.config").values

	local toggle_telescope = function()
		local file_paths = {}
		for _, item in ipairs(harpoon:list().items) do
			table.insert(file_paths, item.value)
		end

		require("telescope.pickers")
			.new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({
					results = file_paths,
				}),
				previewer = telescope.file_previewer({}),
				sorter = telescope.generic_sorter({}),
			})
			:find()
	end

	return toggle_telescope
end

local get_keybindings = function()
	local file_tree = require("file_tree")
	local telescope = require("telescope.builtin")
	local telescope_dap = require("telescope").extensions.dap
	local dap = require("dap")
	local dap_widgets = require("dap.ui.widgets")
	local ts_context = require("treesitter-context")
	local harpoon = require('harpoon')
	local keybindings = {
		a = { vim.lsp.buf.code_action, "code action" },
		b = {
			name = "buffer",
			f = { vim.lsp.buf.format, "format" },
		},
		c = {
			name = "check",
			d = {
				'<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>',
				"debug nearest test",
			},
			f = {
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				"run all tests in this file",
			},
			o = {
				"<cmd>Neotest output<cr>",
				"open test output window",
			},
			p = {
				"<cmd>Neotest output-panel toggle<cr>",
				"toggle test output panel",
			},
			q = {
				"<cmd>Neotest stop<cr>",
				"stop tests",
			},
			s = {
				"<cmd>Neotest summary<cr>",
				"show summary",
			},
			t = {
				"<cmd>Neotest run<cr>",
				"run nearest test",
			},
		},
		D = { vim.lsp.buf.type_definition, "type definition" },
		d = {
			name = "debugger",
			b = { dap.set_breakpoint, "set breakpoint" },
			c = { telescope_dap.commands, "commands" },
			C = { telescope_dap.configurations, "configurations" },
			f = { telescope_dap.frames, "frames" },
			h = { dap_widgets.hover, "dap hover" },
			i = { dap.step_into, "step into" },
			l = { telescope_dap.list_breakpoints, "list breakpoints" },
			n = { dap.continue, "continue debugger" },
			o = { dap.step_over, "step over" },
			O = { dap.step_out, "step out" },
			p = { dap_widgets.preview, "dap preview" },
			r = { dap.repl.open, "open REPL" },
			q = { dap.terminate, "stop dap" },
			R = { dap.run_last, "run last" },
			s = {
				function()
					dap_widgets.centered_float(dap_widgets.scopes)
				end,
				"dap scopes",
			},
			t = { dap.toggle_breakpoint, "toggle breakpoint" },
			v = { telescope_dap.variables, "variables" },
		},
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
			name = "find",
			f = { telescope.find_files, "find file" },
			g = { telescope.live_grep, "grep" },
			b = { telescope.buffers, "find buffer" },
			H = { telescope.help_tags, "help tags" },
			m = { telescope.marks, "find marks" },
			r = { telescope.lsp_references, "find references" },
			s = { telescope.treesitter, "structure (treesitter)" },
		},
		g = {
			name = "goto",
			d = { vim.lsp.buf.definition, "definition" },
			D = { vim.lsp.buf.declaration, "declaration" },
			i = { vim.lsp.buf.implementation, "implementation" },
			r = { vim.lsp.buf.references, "references" },
			p = { vim.lsp.diagnostic.goto_prev, "previous" },
			n = { vim.lsp.buf.format, "format" },
		},
		h = {
			name = "harpoon",
			a = { 
				function()
					harpoon:list():append()
				end,
				"add mark",
			},
			h = { harpoon_telescope_config(), "harpoon marks" },
			j = { harpoon:list():next(), "next mark" },
			k = { harpoon:list():prev(), "previous mark" },
		},
		H = { vim.lsp.buf.hover, "hover window" },
		l = {
			name = "lsp",
			A = {
				vim.lsp.buf.add_workspace_folder,
				"add workspace",
			},
			R = {
				vim.lsp.buf.remove_workspace_folder,
				"remove workspace folder",
			},
		},
		r = { vim.lsp.buf.rename, "rename" },
		s = {
			name = "show",
			s = {
				vim.lsp.buf.signature_help,
				"signature",
			},
		},
		t = {
			name = "tree",
			t = { file_tree.show, "toggle" },
			b = { file_tree.buffers, "buffers" },
			g = { file_tree.git, "git status" },
		},
		T = {
			name = "treesitter",
			g = {
				function()
					ts_context.go_to_context(vim.v.count1)
				end,
				"go to context",
			},
		},
		v = {
			name = "git",
			b = {
				"<cmd>GitBlameToggle<cr>",
				"toggle git blame",
			},
			s = { telescope.git_status, "git status" },
		},
	}
	return keybindings
end

return get_keybindings
