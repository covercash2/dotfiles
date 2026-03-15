# my openssh config options

{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    # permitRootLogin = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
