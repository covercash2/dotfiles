local winbar_spec = {
	"fgheng/winbar.nvim",
	dependencies = { "SmiteshP/nvim-navic" },
	opts = {},
}

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

return {
	winbar = winbar_spec,
}
