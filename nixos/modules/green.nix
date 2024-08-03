# my server config

{ config, lib, pkgs, ... }:

{
  # disable intel integrated graphics kernel module
  boot.kernelParams = [ "module_blacklist=i915" ];
  networking.hostName = "green";

	services.tailscale.enable = true;

	networking.firewall = {
		enable = true;
		allowedTCPPorts = [
      30000 # foundry VTT
      8123  # home assistant
		];
	};

	fileSystems."/mnt/space" = {
		device = "/dev/disk/by-label/Space";
		fsType = "ext4";
	};

	virtualisation.containers.enable = true;
	virtualisation = {
		podman = {
			enable = true;

			# Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
		};
	};

	environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
	];
}

