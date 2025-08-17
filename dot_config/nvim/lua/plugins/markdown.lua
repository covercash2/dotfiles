return {
	{
		"iamcco/markdown-preview.nvim",

		build = "cd app; yarn install",
		keys = {
			{
				"<leader>rm",
				"<cmd>MarkdownPreview<cr>",
				desc = "run MarkdownPreview",
			},
		},
		ft = { "markdown" },
		cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},
	{
		"jghauser/follow-md-links.nvim",
	},
}
