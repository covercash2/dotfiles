{ pkgs, ... }:

{
  xdg.configFile = {
    source = ./container;
    recursive = true;
  };
}
