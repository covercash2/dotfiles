local recording_symbol = function()
	local register = vim.fn.reg_recording()
	if register == "" then
		return ""
	end
	return "󰑋 " .. register
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			theme = "auto",
			sections = {
				lualine_c = {
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
				lualine_x = {
					recording_symbol,
				},
			},
		})
	end,
}
