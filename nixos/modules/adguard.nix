# adguard DNS server

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    # only applies to the admin UI port, not DNS ports
    openFirewall = true;
    mutableSettings = true;
  };
}
