local wezterm = require 'wezterm';

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Andromeda'
--config.color_scheme = 'GitHub Dark'

config.window_frame = {
	active_titlebar_bg = '#020202',
	font_size = 11.0,
	inactive_titlebar_bg = '#555555',
}

--config.colors = {
--	background = '#000000',
--	tab_bar = {
--		active_tab = {
--			bg_color = '#000000',
--			fg_color = '#c0c0c0',
--		},
--	},
--}

return config
