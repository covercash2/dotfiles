{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "hoss";
    interfaces.enp5s0 = {
      useDHCP = false;
      # this feels like kind of a land mine
      ipv4.addresses = [{
        address = "192.168.2.136";
        prefixLength = 24;
      }];
      wakeOnLan = {
        enable = true;
      };
    };
    defaultGateway = "192.168.2.1";
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  services = {
    tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };
    blueman.enable = true;
  };

  networking.firewall = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    devenv
    direnv
    nvidia-container-toolkit
    zenith-nvidia
  ];

  users = {
    groups = {
      # huggingface users
      hf.name = "hf";
    };
    users = {
      chrash = {
        extraGroups = [
          "hf" # huggingface
        ];
        packages = with pkgs; [
          #python313Packages.huggingface-hub
          # mistral-rs
        ];
        openssh.authorizedKeys.keyFiles = [
          (builtins.fetchurl {
            url = "https://github.com/covercash2.keys";
            sha256 = "0c6zpk19saxk0vfgwlkip0fcb6hp4nz3qwrfr0zs2z76qwxxjkbd";
          })
        ];
      };
    };
  };

  fileSystems = {
    "/mnt/space" = {
      device = "/dev/disk/by-label/space";
      fsType = "ext4";
    };
  };

  # containers
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers = {
      # prometheus exporter for system info
      node_exporter = {
        image = "quay.io/prometheus/node-exporter:latest";
        volumes = ["/:/host:ro,rslave"];
        pull = "newer";
        extraOptions = [ "--network=host" "--pid=host" ];
        cmd = [ "--path.rootfs=/host" ];
      };
    };
  };
}
