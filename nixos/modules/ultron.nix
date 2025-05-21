# Ultron service config

{ config, lib, pkgs, inputs, ultron, ... }:

let
  system = pkgs.system;
in
{
  imports = [
    ultron.nixosModules.${system}.default
  ];

  services.ultron = {
    enable = true;

    environmentFile = "/mnt/space/ultron/secrets";
    port = 9000;
  };
}
