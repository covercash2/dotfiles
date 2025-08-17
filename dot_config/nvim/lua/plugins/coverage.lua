return {
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
}
