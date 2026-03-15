local neotest = {
	"nvim-neotest/neotest",
	dependencies = {
		"haydenmeade/neotest-jest",
		"marilari88/neotest-vitest",
	},
}

local dap = {
	"mxsdev/nvim-dap-vscode-js",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("dap-vscode-js").setup({
			adapters = { "pwa-node" },
			debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
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
	end,
}

local debug = {
	"microsoft/vscode-js-debug",
	build = "npm install --legacy-peer-deps; npx gulp vsDebugServerBundle; mv dist out",
}

return {
	neotest,
	dap,
	debug,
}
