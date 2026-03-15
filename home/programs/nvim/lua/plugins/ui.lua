local winbar_spec = {
	"fgheng/winbar.nvim",
	dependencies = { "SmiteshP/nvim-navic" },
	init = function()
		vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
	end,
	opts = {},
}

local increase_window_size_right = function()
	local window = vim.api.nvim_get_current_win()
	local current_width = vim.api.nvim_win_get_width(window)
	vim.api.nvim_win_set_width(window, current_width + 5)
end

return {
	winbar_spec,
}
