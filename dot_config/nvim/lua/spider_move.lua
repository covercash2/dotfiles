local spider = {
	"chrisgrieser/nvim-spider",
	config = function()
		local spider = require('spider')

		local w = function()
			spider.motion('w')
		end
		local e = function()
			spider.motion('e')
		end
		local b = function()
			spider.motion('b')
		end

		vim.keymap.set(
			{ "n", "o", "x" },
			"w",
			w,
			{ desc = "Spider w" }
		)
		vim.keymap.set(
			{ "n", "o", "x" },
			"e",
			e,
			{ desc = "Spider e" }
		)
		vim.keymap.set(
			{ "n", "o", "x" },
			"b",
			b,
			{ desc = "Spider b" }
		)
	end,
}

return {
	spec = spider,
}
