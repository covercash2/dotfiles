# Ultron service config

{ config, lib, pkgs, ... }:

let
  ultron = builtins.getFlake "github:covercash2/ultron";
in
{
  imports = [
    ultron.nixosModules.${pkgs.system}.default
  ];

  services.ultron = {
    enable = true;

    environmentFile = "/mnt/space/ultron/secrets";
  };
}
