local jsonpath_spec = {
	"phelipetls/jsonpath.nvim",
	ft = "json",
	dependencies = { "nvim-treesitter/nvim-treesitter", "fgheng/winbar.nvim" },
}

local jq_playground_spec = {
	"yochem/jq-playground.nvim",
	keys = {
		{ "<leader>jq", vim.cmd.JqPlayground, desc = "jq playground" },
	},
}

return {
	jsonpath_spec,
	jq_playground_spec,
}
