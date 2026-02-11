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
    apollo_router = {
      enable = true;
      port = 4000;
    };

    nixos-cli = {
      enable = true;
      config = {
        use_nvd = true;
      };
    };

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

      routes = {
        apollo_router = {
          url = "graphql.green.chrash.net";
          description = "Apollo GraphQL Router route";
        };
        prometheus = {
          url = "prometheus.green.chrash.net";
          description = "Prometheus metrics UI";
        };
        ultron = {
          url = "ultron.green.chrash.net";
          description = "Main route for Ultron bot";
        };
        adguard = {
          url = "adguard.green.chrash.net";
          description = "AdGuard DNS route";
        };
        grafana = {
          url = "grafana.green.chrash.net";
          description = "Grafana monitoring dashboard";
        };
        postgres = {
          url = "db.green.chrash.net";
          description = "PostgreSQL database route";
        };
        homeassistant = {
          url = "homeassistant.green.chrash.net";
          description = "Home Assistant route";
        };
        frigate = {
          url = "frigate.green.chrash.net";
          description = "Frigate for NVR and AI detection";
        };
        foundry = {
          url = "foundry.green.chrash.net";
          description = "Foundry Virtual Tabletop route";
        };
        zwave = {
          url = "zwave.green.chrash.net";
          description = "Z-Wave JS controls";
        };
      };
    };

    # reverse proxy
    caddy = {
      enable = true;

      virtualHosts = {
        "home.green.chrash.net" = {
          extraConfig = ''
            handle_path /healthcheck {
              respond "OK"
            }
          '';
        };

        "green.faun-truck.ts.net" = {
          extraConfig = ''
            handle_path /healthcheck {
              respond "OK"
            }
          '';
        };

        ${config.services.green.routes.apollo_router.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.apollo_router.port}
          '';
        };

        ${config.services.green.routes.foundry.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:30000
          '';
        };

        ${config.services.green.routes.adguard.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.adguardhome.port}
          '';
        };

        ${config.services.green.routes.homeassistant.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:8123
          '';
        };

        ${config.services.green.routes.ultron.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.ultron.port} {
              health_uri /healthcheck
            }
          '';
        };

        ${config.services.green.routes.frigate.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:8971
          '';
        };

        ${config.services.green.routes.grafana.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.grafana.settings.server.http_port}
          '';
        };

        ${config.services.green.routes.prometheus.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.prometheus.port}
          '';
        };

        ${config.services.green.routes.postgres.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.postgresql.settings.port}
          '';
        };

        ${config.services.green.routes.zwave.url} = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${config.services.zwave-js-ui.settings.PORT}
          '';
        };

        # ${config.services.green.routes.immich.url} = {
        #   extraConfig = ''
        #     tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
        #     reverse_proxy localhost:${toString config.services.immich.port}
        #   '';
        # };
      };

      configFile = pkgs.writeText "Caddyfile" ''
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

        ${config.services.green.routes.apollo_router.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.apollo_router.port}
        }


        ${config.services.green.routes.foundry.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:30000
        }

        ${config.services.green.routes.adguard.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.adguardhome.port}
        }

        ${config.services.green.routes.homeassistant.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:8123
        }

        ${config.services.green.routes.ultron.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.ultron.port} {
            health_uri /healthcheck
          }
        }

        ${config.services.green.routes.frigate.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:8971
        }

        ${config.services.green.routes.grafana.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.grafana.settings.server.http_port}
        }

        ${config.services.green.routes.prometheus.url} {
        # prometheus.green.chrash.net {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.prometheus.port}
        }

        ${config.services.green.routes.postgres.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${toString config.services.postgresql.settings.port}
        }

        ${config.services.green.routes.zwave.url} {
          tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
          reverse_proxy localhost:${config.services.zwave-js-ui.settings.PORT}
        }

        # immich.green.chrash.net {
        #   tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
        #   reverse_proxy localhost:${toString config.services.immich.port}
        # }
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
        {
          job_name = "hoss_system";
          static_configs = [
            {
              targets = [ "hoss:9100" ];
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

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.containers = {
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
  };

  environment.systemPackages = with pkgs; [
    bat-extras.batman
    btrfs-progs
    dive
    ffmpeg
    jc # parse CLI output to JSON or YAML

    mkcert # create certificates and a local CA
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

    # Javascript
    deno
    nodejs_24
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
      "podman"
    ];
    packages = with pkgs; [
      gnumake
      lazysql
      minica # mini certificate authority for generating certs for my services
      rainfrog # database view TUI
      rustup
    ];
  };
}
