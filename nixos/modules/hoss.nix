{ config, lib, pkgs, ... }:

{
  networking.hostName = "hoss";

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  services = {
    tailscale.enable = true;
    blueman.enable = true;
  };

  networking.firewall = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  fileSystems = {
    "/mnt/space" = {
      device = "/dev/disk/by-label/space";
      fsType = "ext4";
    };
  };
}
