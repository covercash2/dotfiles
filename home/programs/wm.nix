# Migrated from dot_config/hypr/hyprland.conf
{ pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    extraConfig = builtins.readFile ./hypr/hyprland.conf;
  };
}
