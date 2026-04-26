{ config, lib, ... }:

let
  # Web UI is at base port + 1
  webUIPort = config.services.sunshine.settings.port + 1;
in
{
  services = {
    sunshine = {
      enable = true;
      # necessary for playing DRM content
      capSysAdmin = true;
      settings = {
        port = 47989; # Base streaming port (web UI will be 47990)
      };
    };

    green = {
      routes = {
        sunshine = {
          url = "sunshine.${config.networking.hostName}.chrash.net";
          description = "Sunshine remote desktop route";
        };
      };
    };
    caddy = {
      virtualHosts = {
        ${config.services.green.routes.sunshine.url} = {
          extraConfig = ''
            tls ${config.services.mkcert-shared.certPath} ${config.services.mkcert-shared.keyPath}
            reverse_proxy https://localhost:${toString webUIPort} {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };
      };
    };
  };
}
