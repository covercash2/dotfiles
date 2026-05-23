# Migrated from dot_config/hypr/hyprland.conf
{ pkgs, lib, withDesktop ? true, ... }:

{
  wayland.windowManager.hyprland = lib.mkIf (pkgs.stdenv.isLinux && withDesktop) {
    enable = true;
    configType = "hyprlang";
    extraConfig = builtins.readFile ./hypr/hyprland.conf;
  };
}
