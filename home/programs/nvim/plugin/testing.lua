-- Jest config for monorepo support
local jest_config = {
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
	cwd = function()
		return vim.fn.getcwd()
	end,
	jest_test_discovery = true,
}

-- Neotest
require("neotest").setup({
	discovery = {
		enabled = false,
	},
	adapters = {
		require("neotest-jest")(jest_config),
		require("rustaceanvim.neotest"),
	},
})

-- Coverage
local function get_lcov_file()
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

-- Neotest keymaps
local map = vim.keymap.set
map("n", "<leader>cd", '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>', { desc = "debug nearest test" })
map("n", "<leader>cf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "run all tests in this file" })
map("n", "<leader>co", "<cmd>Neotest output<cr>", { desc = "open test output window" })
map("n", "<leader>cp", "<cmd>Neotest output-panel toggle<cr>", { desc = "toggle test output panel" })
map("n", "<leader>cq", "<cmd>Neotest stop<cr>", { desc = "stop tests" })
map("n", "<leader>cs", "<cmd>Neotest summary<cr>", { desc = "neotest summary" })
map("n", "<leader>ct", "<cmd>Neotest run<cr>", { desc = "run nearest test" })
