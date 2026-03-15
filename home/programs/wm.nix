# Migrated from dot_config/hypr/hyprland.conf
{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hypr/hyprland.conf;
  };
}
