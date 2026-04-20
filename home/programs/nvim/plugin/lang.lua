-- Rustaceanvim
vim.g.rustaceanvim = {
	-- TODO update to lspmux
	-- https://github.com/mrcjkb/rustaceanvim/issues/870
	ra_multiplex = {
		enable = true,
		host = "127.0.0.1",
		port = 27631,
	},
}

vim.keymap.set("n", "<leader>gX", "<cmd>RustLsp externalDocs<cr>", { desc = "Open external docs" })

-- Clangd extensions
require("clangd_extensions").setup()

-- CMake tools
require("cmake-tools").setup({
	cmake_command = "cmake",
	cmake_build_directory = "build",
	cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
	cmake_build_options = {},
	cmake_console_size = 10,
	cmake_show_console = "always",
	cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" },
	cmake_dap_open_command = function()
		require("dap").repl.open()
	end,
	cmake_variants_message = {
		short = { show = true },
		long = { show = true, max_length = 40 },
	},
})

-- Guard (formatting / linting)
local ft = require("guard.filetype")

ft("python"):fmt("black"):lint("pylint")

ft("html,htmldjango"):fmt("djhtml"):lint({
	cmd = "djlint",
	stdin = true,
	args = { "-", "--profile=jinja" },
	parse = function(result, bufnr)
		local lint = require("guard.lint")
		local diags = {}
		local lines = vim.split(result, "\n")
		for i, line in ipairs(lines) do
			local lnum = line:match("^%u%d+%s(%d+)")
			if lnum then
				diags[#diags + 1] = lint.diag_fmt(bufnr, tonumber(lnum) - 1, 0, lines[i]:gsub("\t", ""), 2, "djlint")
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

-- DAP (TypeScript/JavaScript)
require("dap-vscode-js").setup({
	adapters = { "pwa-node" },
	debugger_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/vscode-js-debug",
})

for _, language in ipairs({ "typescript", "javascript" }) do
	require("dap").configurations[language] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "launch dist",
			program = "${workspaceFolder}/dist/index.js",
			cwd = "${workspaceFolder}",
			envFile = "${workspaceFolder}/dev.env",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
	}
end

-- jq playground
vim.keymap.set("n", "<leader>jq", vim.cmd.JqPlayground, { desc = "jq playground" })

-- DAP keymaps
local map = vim.keymap.set
local dap = require("dap")
local dap_widgets = require("dap.ui.widgets")
local telescope_dap = require("telescope").extensions.dap

map("n", "<leader>dc", telescope_dap.commands, { desc = "commands" })
map("n", "<leader>dC", telescope_dap.configurations, { desc = "configurations" })
map("n", "<leader>df", telescope_dap.frames, { desc = "frames" })
map("n", "<leader>dh", dap_widgets.hover, { desc = "dap hover" })
map("n", "<leader>di", dap.step_into, { desc = "step into" })
map("n", "<leader>dl", telescope_dap.list_breakpoints, { desc = "list breakpoints" })
map("n", "<leader>dn", dap.continue, { desc = "continue debugger" })
map("n", "<leader>do", dap.step_over, { desc = "step over" })
map("n", "<leader>dO", dap.step_out, { desc = "step out" })
map("n", "<leader>dp", dap_widgets.preview, { desc = "dap preview" })
map("n", "<leader>dr", dap.repl.open, { desc = "open REPL" })
map("n", "<leader>dq", dap.terminate, { desc = "stop dap" })
map("n", "<leader>dR", dap.run_last, { desc = "run last" })
map("n", "<leader>ds", function()
	dap_widgets.centered_float(dap_widgets.scopes)
end, { desc = "dap scopes" })
map("n", "<leader>dt", dap.toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dv", telescope_dap.variables, { desc = "variables" })
