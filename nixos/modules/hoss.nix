{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "hoss";
    interfaces.enp5s0 = {
      useDHCP = false;
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
  nixpkgs.config.cudaSupport = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # enable CUDA in containers
    nvidia-container-toolkit = {
      enable = true;
      # https://forums.developer.nvidia.com/t/nvidia-container-toolkit-podman-error-error-setting-up-cdi-devices-unresolvable-cdi-devices-nvidia-com-gpu-all/272286
      device-name-strategy = "type-index";
    };
  };

  services = {
    tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };
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

    caddy = {
      enable = true;

      virtualHosts = {
        "hoss.faun-truck.ts.net" = {
          extraConfig = ''
            handle_path /llm/* {
              reverse_proxy localhost:11434 {
                health_uri /
              }
            }
            respond "hello"

            ${config.services.sunshine.routes.apollo_router.url} {
              tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
              reverse_proxy localhost:${toString config.services.apollo_router.port}
            }
          '';
        };
        "sunshine.hoss.chrash.net" = {
          tlsCert = config.services.mkcert.certPath;
          tlsKey = config.services.mkcert.keyPath;
          extraConfig = ''
            handle_path /llm/* {
              reverse_proxy localhost:11434 {
                health_uri /
              }
            }
            respond "hello"

            ${config.services.sunshine.routes.apollo_router.url} {
              tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
              reverse_proxy localhost:${toString config.services.apollo_router.port}
            }
          '';
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      443
      14554 # virtualisation.oci-containers.mistral_rs.ports
      9100 # node_export for prometheus system resource metrics
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
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
          python313Packages.huggingface-hub
          # mistral-rs
        ];
      };
      mistral = {
        description = "user to restrict the mistralrs-server";
        group = "hf";
        isSystemUser = true;
        homeMode = "774";
        home = "/mnt/space/mistral";
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
      # mistral_rs = {
      #   podman.user = "mistral";
      #   image = "ghcr.io/ericlbuehler/mistral.rs:cuda-90-0.4";
      #   ports = [ "14554:80" ];
      #   volumes = [
      #     "/mnt/space/mistral"
      #     "/home/chrash/.cache/huggingface/:/root/.cache/huggingface/:ro"
      #   ];
      #   pull = "newer";
      #   devices = [ "nvidia.com/gpu=gpu0" ];
      #   environment = {
      #     RUST_LOG = "debug";
      #   };
      #   entrypoint = "mistralrs-server";
      #   cmd = [
      #     # ordering matters: --token-source is a flag for the root
      #     # https://github.com/EricLBuehler/mistral.rs?tab=readme-ov-file#getting-models-from-hugging-face-hub
      #     # looking in ~/.cache/huggingface/token
      #     "--token-source" "cache"
      #     "--port" "80"
      #     "--isq" "Q4K"
      #     "plain"
      #     "--model-id" "deepseek-ai/DeepSeek-R1"
      #   ];
      # };
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
