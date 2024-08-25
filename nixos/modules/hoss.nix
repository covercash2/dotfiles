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
		ollama = {
			enable = true;
			user = "ollama";
			models = "/mnt/space/ollama/models";
			home = "/mnt/space/ollama";
			host = "0.0.0.0";
			port = 11434;
			openFirewall = true;
		};
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
