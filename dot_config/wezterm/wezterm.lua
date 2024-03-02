local wezterm = require("wezterm")

local config = {
	--default_prog = { '/opt/homebrew/bin/nu' },
	-- https://wezfurlong.org/wezterm/colorschemes/index.html
	--		color_scheme = "Andromeda",
	--	color_scheme = 'GitHub Dark',
	color_scheme = "Tokyo Night",
	font = wezterm.font("Fira Code"),
	colors = {
		visual_bell = "#777777",
	},
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	window_frame = {
		font_size = 13.0,
		active_titlebar_bg = "#020202",
		inactive_titlebar_bg = "#555555",
	},
	visual_bell = {
		fade_in_duration_ms = 100,
		fade_out_duration_ms = 200,
	},
}

return config
