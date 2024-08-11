{ config, lib, pkgs, ... }:

{
  networking.hostName = "hoss";

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
  };

	fileSystems = {
		"/mnt/space" = {
			device = "/dev/disk/by-label/space";
			fsType = "ext4";
		};
	};
}
