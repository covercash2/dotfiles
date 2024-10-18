# my server config

{ config, lib, pkgs, ... }:

{
  # disable intel integrated graphics kernel module
  boot.kernelParams = [ "module_blacklist=i915" ];

  networking = {
    hostName = "green";
    useDHCP = false;
    interfaces.enp5s0 = {
      ipv4.addresses = [{
        address = "192.168.2.216";
        prefixLength = 24;
      }];
    };
		defaultGateway = {
			address = "192.168.2.1";
			interface = "enp5s0";
		};
  };

  services = {
    tailscale.enable = true;
    # media hosting
    jellyfin = {
      enable = true;
      openFirewall = true;
      cacheDir = "/mnt/media/jellyfin/cache";
      configDir = "/mnt/media/jellyfin/config";
      dataDir = "/mnt/media/jellyfin/data";
      logDir = "/mnt/media/jellyfin/logs";
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
       };
      };
    };
  };


  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      30000 # foundry VTT
      8123  # home assistant
      3000  # Grafana
    ];
  };

  fileSystems = {
    # extra space
    # old home folder, extra files, miscellaneous space
    "/mnt/space" = {
      device = "/dev/disk/by-label/Space";
      fsType = "ext4";
    };
    # media: movies, some other miscellaneous files
    "/mnt/media" = {
      device = "/dev/disk/by-label/media";
      fsType = "ext4";
    };
    # games: fast (SATA SSD) storage for games etc
    "/mnt/games" = {
      device = "/dev/disk/by-label/games";
      fsType = "btrfs";
    };
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
    btrfs-progs
    dive
    podman-tui
    podman-compose
    zenith-nvidia
  ];

  users.groups = {
    iot = {
      gid = 992;
    };
  };
  users.users.chrash = {
    extraGroups = [
      "iot"
    ];
  };
}

