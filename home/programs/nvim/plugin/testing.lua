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
