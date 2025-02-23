# my server config

{ pkgs, ... }:

{
  # disable intel integrated graphics kernel module
  boot.kernelParams = [ "module_blacklist=i915" ];

  networking = {
    hostName = "green";
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.2.216";
        prefixLength = 24;
      }];
    };
  };

  services = {
    tailscale.enable = true;

    # reverse proxy
    caddy = {
      enable = true;

      configFile = pkgs.writeText "Caddyfile" ''
        foundry.green.chrash.net {
          reverse_proxy localhost:30000
        }

        db.green.chrash.net {
          reverse_proxy localhost:5432
        }

        adguard.green.chrash.net {
          reverse_proxy localhost:3000
        }

        green.tail33d42.ts.net {
          reverse_proxy localhost:9876
        }
      '';

    };

    # shared shell history, depends on postgresql
    atuin = {
      enable = true;
      host = "0.0.0.0";
      port = 8888;
      openFirewall = true;
      openRegistration = true;

      database = {
        createLocally = true;
      };
    };

    # media hosting
    jellyfin = {
      enable = true;
      openFirewall = true;
      cacheDir = "/mnt/media/jellyfin/cache";
      configDir = "/mnt/media/jellyfin/config";
      dataDir = "/mnt/media/jellyfin/data";
      logDir = "/mnt/media/jellyfin/logs";
    };

    postgresql = {
      enable = true;
      enableTCPIP = true;
      dataDir = "/mnt/space/postgres";
      settings = {
        ssl = true;
        port = 5432; # default port echoed here for docs
      };
      authentication = pkgs.lib.mkOverride 10 ''
        ## allow local to connect
        #type database  DBuser origin-address auth-method
        local all       all                   trust
        local sameuser  all     peer          map=superuser_map
        host  sameuser  all     ::1/128       scram-sha-256
       '';
      identMap = ''
        # ArbitraryMapName systemUser DBUser
        superuser_map      root       postgres
        superuser_map      postgres   postgres
        # Let other names login as themselves
        superuser_map      /^(.*)$    \1
      '';
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 9876;
        };
      };
    };
    # metrics
    prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "prometheus";
          scrape_interval = "5s";
          static_configs = [
            {
              targets = ["localhost:9090"];
            }
          ];
        }
        {
          job_name = "homeassistant";
          static_configs = [
            {
              targets = ["localhost:8123"];
            }
          ];
        }
        {
          job_name = "green_system";
          static_configs = [
            {
              targets = ["localhost:9100"];
            }
          ];
        }
      ];
    };
  };


  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      30000 # foundry VTT
      8123  # home assistant
      9876  # Grafana
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
  virtualisation.oci-containers.containers = {
    actual_budget = {
      image = "docker.io/actualbudget/actual-server:latest";
      ports = ["5006:5006"];
      volumes = ["/mnt/media/actual_budget"];
      pull = "newer";
    };
    # prometheus exporter for system info
    node_exporter = {
      image = "quay.io/prometheus/node-exporter:latest";
      volumes = ["/:/host:ro,rslave"];
      pull = "newer";
      extraOptions = [ "--network=host" "--pid=host" ];
      cmd = [ "--path.rootfs=/host" ];
    };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    dive
    nss # for certutils
    openssl
    pgcli # better CLI for Postgres
    podman-tui
    podman-compose
    zenith-nvidia
  ];

  users = {
    groups = {
      iot = {
        gid = 992;
      };
    };
  };
  users.users.chrash = {
    extraGroups = [
      "iot"
    ];
    packages = with pkgs; [
      minica # mini certificate authority for generating certs for my services
    ];
  };
}

