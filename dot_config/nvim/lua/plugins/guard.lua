return {
	"nvimdev/guard.nvim",
	dependencies = { "nvimdev/guard-collection" },
	config = function()
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
}
