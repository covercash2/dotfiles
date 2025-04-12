hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.PaperWM = {
    url = "https://github.com/mogenson/PaperWM.spoon",
    desc = "PaperWM.spoon repository",
    branch = "release",
}

-- https://configure.zsa.io/moonlander/layouts/0r5z3/latest/0
local focus_mod = {"cmd", "alt", "ctrl"}
local move_mod = {"cmd", "alt", "ctrl", "shift"}

spoon.SpoonInstall:andUse("PaperWM", {
    repo = "PaperWM",
    config = { screen_margin = 16, window_gap = 2 },
    start = true,
    hotkeys = {
      focus_left = {focus_mod, "h"},
      focus_right = {focus_mod, "l"},
      focus_down = {focus_mod, "j"},
      focus_up = {focus_mod, "k"},

      swap_left = {move_mod, "h"},
      swap_right = {move_mod, "l"},
      swap_down = {move_mod, "j"},
      swap_up = {move_mod, "k"},

      center_window = {focus_mod, "c"},
      full_width = {focus_mod, "f"},
      cycle_width = {focus_mod, "w"},

      slurp_in = {focus_mod, "i"},
      barf_out = {focus_mod, "o"},

      toggle_floating = {move_mod, "f"},

      switch_space_l = {focus_mod, ","},
      switch_space_r = {focus_mod, "."},
      switch_space_1 = {focus_mod, "1"},
      switch_space_2 = {focus_mod, "2"},
      switch_space_3 = {focus_mod, "3"},
      switch_space_4 = {focus_mod, "4"},
      switch_space_5 = {focus_mod, "5"},
      switch_space_6 = {focus_mod, "6"},
      switch_space_7 = {focus_mod, "7"},
      switch_space_8 = {focus_mod, "8"},
      switch_space_9 = {focus_mod, "9"},

      move_window_1 = {move_mod, "1"},
      move_window_2 = {move_mod, "2"},
      move_window_3 = {move_mod, "3"},
      move_window_4 = {move_mod, "4"},
      move_window_5 = {move_mod, "5"},
      move_window_6 = {move_mod, "6"},
      move_window_7 = {move_mod, "7"},
      move_window_8 = {move_mod, "8"},
      move_window_9 = {move_mod, "9"},
    }
})

hs.hotkey.bind({"cmd", "alt", "shift", "ctrl"}, "R", function()
  hs.alert.show("Hello World!")
end)
