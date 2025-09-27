-- testing stuff

-- javascript testing shit
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
	cwd = function(path)
		return vim.fn.getcwd()
	end,
	jest_test_discovery = true,
}

return {
	"nvim-neotest/neotest",

	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
		"mrcjkb/rustaceanvim",
	},
  config = function()
    require("neotest").setup {
      discovery = {
        enabled = false,
      },
      adapters = {
        require("neotest-jest")(jest_config),
        require("rustaceanvim.neotest"),
      },
    }
  end,
}
