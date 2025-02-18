# adguard DNS server

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    # only applies to the admin UI port, not DNS ports
    openFirewall = true;
    mutableSettings = true;
    port = 3000; # the port for the HTTP portal
    settings = {};
  };

  networking.firewall = {
    allowedTCPPorts = [
      53 # unsecured DNS
    ];
  };
}
