# my server config

{ pkgs, config, ... }:

{
  # disable intel integrated graphics kernel module
  boot.kernelParams = [ "module_blacklist=i915" ];

  networking = {
    hostName = "green";
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.2.216";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
    defaultGateway = "192.168.2.1";
  };

  services = {
    mkcert = {
      enable = true;
      domain = "*.green.chrash.net";
    };

    tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };

    green = {
      enable = true;

      port = 47336;
      caPath = config.services.mkcert.caPath;
    };

    # reverse proxy
    caddy = {
      enable = true;

      configFile = pkgs.writeText "Caddyfile" ''
        foundry.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:30000
        }

        adguard.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.adguardhome.port}
        }

        homeassistant.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:8123
        }

        home.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.green.port} {
            health_uri /healthcheck
          }
        }

        green.faun-truck.ts.net {

          reverse_proxy localhost:${toString config.services.green.port} {
            health_uri /healthcheck
          }
        }

        ultron.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.ultron.port} {
            health_uri /healthcheck
          }
        }

        frigate.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:8971
        }

        grafana.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.grafana.settings.server.http_port}
        }

        prometheus.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.prometheus.port}
        }

        db.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.postgresql.settings.port}
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

    # video surveillance
    # https://docs.frigate.video/frigate/installation#ports
    frigate = {
      enable = true;
      hostname = "frigate.green";
      # video acceleration API
      vaapiDriver = "nvidia";

      settings = {
        mqtt = {
          enabled = true;
          host = "localhost";
        };

        cameras = {
          door = {
            ffmpeg.inputs = [
              {
                path = "rtsp://chrash:chrash@192.168.2.132:1935";
                roles = [
                  "audio"
                  "detect"
                  "record"
                ];
              }
            ];
          };
        }; # cameras

      }; # settings
    }; # frigate

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
              targets = [ "localhost:9090" ];
            }
          ];
        }
        {
          job_name = "homeassistant";
          static_configs = [
            {
              targets = [ "localhost:8123" ];
            }
          ];
        }
        {
          job_name = "green_system";
          static_configs = [
            {
              targets = [ "localhost:9100" ];
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
      8123 # home assistant
      8971 # frigate
      (config.services.postgresql.settings.port)
      443
      80
      (config.services.ultron.port)
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
    # actual_budget = {
    #   image = "docker.io/actualbudget/actual-server:latest";
    #   ports = [ "5006:5006" ];
    #   volumes = [ "/mnt/media/actual_budget" ];
    #   pull = "newer";
    # };
    # prometheus exporter for system info
    node_exporter = {
      image = "quay.io/prometheus/node-exporter:latest";
      volumes = [ "/:/host:ro,rslave" ];
      pull = "newer";
      extraOptions = [
        "--network=host"
        "--pid=host"
      ];
      cmd = [ "--path.rootfs=/host" ];
    };
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    dive
    ffmpeg
    mkcert # create certificates and a local CA
    nodejs_24
    nss # for certutils
    openssl
    pgcli # better CLI for Postgres
    podman-tui
    podman-compose
    rops # version controllable secrets management
    wol # wake on LAN tool
    zenith-nvidia # system monitor with Nvidia support

    # Python tools
    pyright
    python314
    python3Packages.black
    python3Packages.pip
    python3Packages.python
    ruff
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
      gnumake
      minica # mini certificate authority for generating certs for my services
    ];
  };
}
