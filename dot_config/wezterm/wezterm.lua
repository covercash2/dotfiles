local wezterm = require("wezterm")

local config = {
-- https://wezfurlong.org/wezterm/colorschemes/index.html
		color_scheme = "Andromeda",
--	color_scheme = 'GitHub Dark',
	font = wezterm.font('Fira Code'),
	colors = {
		visual_bell = "#777777",
	},
	window_frame = {
		active_titlebar_bg = "#020202",
		font_size = 11.0,
		inactive_titlebar_bg = "#555555",
	},
	visual_bell = {
		fade_in_duration_ms = 100,
		fade_out_duration_ms = 200,
	},
}

return config
