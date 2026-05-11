{ config, lib, pkgs, ... }:

let
  sunshineWebUIPort = config.services.sunshine.settings.port + 1;
in

{
  boot.kernelModules = [ "uinput" ];

  services.getty.autologinUser = "chrash";

  systemd.user.services.sunshine = {
    wantedBy = lib.mkForce [ "default.target" ];
  };

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

    nvidia-container-toolkit = {
      enable = true;
      # https://forums.developer.nvidia.com/t/nvidia-container-toolkit-podman-error-error-setting-up-cdi-devices-unresolvable-cdi-devices-nvidia-com-gpu-all/272286
      device-name-strategy = "type-index";
    };
  };

  services = {
    tailscale.permitCertUid = "caddy";
    blueman.enable = true;

    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      user = "ollama";
      host = "0.0.0.0";
      port = 11434;
      openFirewall = true;
      models = "/mnt/space/ollama/models";
      home = "/mnt/space/ollama";
    };

    mkcert-shared = {
      enable = true;
      domain = "*.hoss.chrash.net";
      rootCACert = ../certs/ca.pem;
      rootCAKey = config.sops.secrets.ca_key.path;
    };

    caddy = {
      enable = true;
      openFirewall = true;
      virtualHosts."sunshine.hoss.chrash.net" = {
        extraConfig = ''
          tls ${config.services.mkcert-shared.certPath} ${config.services.mkcert-shared.keyPath}
          reverse_proxy https://localhost:${toString sunshineWebUIPort} {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
    };
  };

  networking.firewall = {
    enable = true;
  };

  # trust the homelab shared CA so green's services work without cert errors
  security.pki.certificates = [ (builtins.readFile ../certs/ca.pem) ];

  environment.systemPackages = with pkgs; [
    devenv
    direnv
    ssh-to-age
    zenith-nvidia
  ];

  users = {
    groups = {
      # huggingface users
      hf.name = "hf";
      ollama.name = "ollama";
    };
    users = {
      ollama = {
        isSystemUser = true;
        group = "ollama";
        home = "/mnt/space/ollama";
      };
      chrash = {
        linger = true;
        extraGroups = [
          "hf"    # huggingface
          "video" # /dev/dri access for Sunshine capture
          "input" # /dev/uinput access for virtual input devices
        ];
        packages = with pkgs; [
          #python313Packages.huggingface-hub
          # mistral-rs
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
