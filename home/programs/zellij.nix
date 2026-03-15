# Migrated from dot_config/zellij/config.kdl
# KDL config is linked directly rather than converted to Nix attrsets.
{ ... }:

{
  programs.zellij.enable = true;

  xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;
  xdg.configFile."zellij/layouts".source = ./zellij/layouts;
}
