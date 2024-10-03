local get_keybindings = function()
	local ai = require('ai')
	local file_tree = require("file_tree")
	local telescope = require("telescope.builtin")
	local telescope_dap = require("telescope").extensions.dap
	local dap = require("dap")
	local dap_widgets = require("dap.ui.widgets")
	local ts_context = require("treesitter-context")
	local close_buffers = require("close_buffers")
	-- STOP! don't add more keybindings here
	-- unless you need specific customization,
	-- just define them like normal,
	-- and let which-key figure shit out
	local keybindings = {
		{ "<leader>a", group = "ai" },
		ai.keys,
		-- ai.keys.chat,
		-- ai.keys.pick_prompt,
		-- ai.keys.code_review,

		{ "<leader>b",  group = "buffer" },
		{ "<leader>bf", vim.lsp.buf.format,                                       desc = "format buffer" },
		{ "<leader>bh", function() close_buffers.delete({ type = "hidden" }) end, desc = "close hidden buffers" },
		{ "<leader>bh", function() close_buffers.delete({ type = "other" }) end,  desc = "close other buffers" },

		{ "<leader>c",  group = "check" },
		{
			"<leader>cd",
			'<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>',
			desc = "debug nearest test"
		},
		{
			"<leader>cf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "run all tests in this file",
		},
		{
			"<leader>co",
			"<cmd>Neotest output<cr>",
			desc = "open test output window",
		},
		{
			"<leader>cp",
			"<cmd>Neotest output-panel toggle<cr>",
			desc = "toggle test output panel",
		},
		{
			"<leader>cq",
			"<cmd>Neotest stop<cr>",
			desc = "stop tests",
		},
		{
			"<leader>cs",
			"<cmd>Neotest summary<cr>",
			desc = "neotest summary",
		},
		{
			"<leader>ct",
			"<cmd>Neotest run<cr>",
			desc = "run nearest test",
		},

		{ "<leader>D",  vim.lsp.buf.type_definition,    desc = "type definition" },

		{ "<leader>d",  group = "debugger" },
		{ "<leader>dc", telescope_dap.commands,         desc = "commands" },
		{ "<leader>dC", telescope_dap.configurations,   desc = "configurations" },
		{ "<leader>df", telescope_dap.frames,           desc = "frames" },
		{ "<leader>dh", dap_widgets.hover,              desc = "dap hover" },
		{ "<leader>di", dap.step_into,                  desc = "step into" },
		{ "<leader>dl", telescope_dap.list_breakpoints, desc = "list breakpoints" },
		{ "<leader>dn", dap.continue,                   desc = "continue debugger" },
		{ "<leader>do", dap.step_over,                  desc = "step over" },
		{ "<leader>dO", dap.step_out,                   desc = "step out" },
		{ "<leader>dp", dap_widgets.preview,            desc = "dap preview" },
		{ "<leader>dr", dap.repl.open,                  desc = "open REPL" },
		{ "<leader>dq", dap.terminate,                  desc = "stop dap" },
		{ "<leader>dR", dap.run_last,                   desc = "run last" },
		{
			"<leader>ds",
			function()
				dap_widgets.centered_float(dap_widgets.scopes)
			end,
			desc = "dap scopes",
		},
		{ "<leader>dt", dap.toggle_breakpoint,                   desc = "toggle breakpoint" },
		{ "<leader>dv", telescope_dap.variables,                 desc = "variables" },

		{ "<leader>e",  group = "errors" },
		{ "<leader>el", vim.lsp.diagnostic.get_line_diagnostics, desc = "line diagnostics" },
		-- { "<leader>et", vim.cmd([[TroubleToggle]]),              desc = "trouble" },

		{
			"<leader>f",
			group = "find"
		},
		{
			"<leader>fg",
			group = "git",
		},
		{ "<leader>ff", telescope.find_files,     desc = "find file" },
		-- { "<leader>fg", telescope.live_grep,      desc = "grep" },
		{ "<leader>fb", telescope.buffers,        desc = "find buffer" },
		{ "<leader>fH", telescope.help_tags,      desc = "help tags" },
		{ "<leader>fm", telescope.marks,          desc = "find marks" },
		{ "<leader>fr", telescope.lsp_references, desc = "find references" },
		{ "<leader>fs", telescope.treesitter,     desc = "structure (treesitter)" },

		{
			"<leader>g",
			group = "goto"
		},
		{ "<leader>gd", vim.lsp.buf.definition,       desc = "definition" },
		{ "<leader>gD", vim.lsp.buf.declaration,      desc = "declaration" },
		{ "<leader>gi", vim.lsp.buf.implementation,   desc = "implementation" },
		{ "<leader>gr", vim.lsp.buf.references,       desc = "references" },
		{ "<leader>gp", vim.lsp.diagnostic.goto_prev, desc = "previous" },

		{
			"<leader>h",
			vim.lsp.buf.hover,
			desc = "hover window"
		},

		{
			"<leader>l",
			group = "lsp"
		},
		{ "<leader>lA", vim.lsp.buf.add_workspace_folder,    desc = "add workspace" },
		{ "<leader>la", vim.lsp.buf.code_action,             desc = "code action" },
		{ "<leader>lR", vim.lsp.buf.remove_workspace_folder, desc = "remove workspace folder" },
		{ "<leader>lr", vim.lsp.buf.rename,                  desc = "rename" },
		{ "<leader>ls", vim.lsp.buf.signature_help,          desc = "signature help" },

		{
			"<leader>t",
			group = "tree"
		},
		{ "<leader>tt", file_tree.show,    desc = "toggle" },
		{ "<leader>tb", file_tree.buffers, desc = "buffers" },
		{ "<leader>tg", file_tree.git,     desc = "git status" },

		{
			"<leader>T",
			group = "treesitter"
		},
		{
			"<leader>Tg",
			function()
				ts_context.go_to_context(vim.v.count1)
			end,
			desc = "go to context",
		},

		{ "<leader>v",  group = "git" },
	}
	return keybindings
end

return get_keybindings
