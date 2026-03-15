-- > Use the w, e, b motions like a spider.
-- > Move by subwords and skip insignificant punctuation.

return {
	"chrisgrieser/nvim-spider",

	keys = {
		{
			"w",
			"<cmd>lua require('spider').motion('w')<CR>",
			mode = { "n", "o", "x" },
			desc = "move to the start of the next subword",
		},
		{
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			mode = { "n", "o", "x" },
			desc = "move to the end of the next subword",
		},
		{
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			mode = { "n", "o", "x" },
			desc = "move to the start of the previous subword",
		},
	},
	opts = {
		skipInsignificantPunctuation = true,
		subwordMovement = true,
	},
}
