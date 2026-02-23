{ config, ... }:

{
  services.sunshine = {
    enable = true;
    # necessary for playing DRM content
    capSysAdmin = true;
  };

  services = {
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
        "sunshine.${config.networking.hostName}.chrash.net" = {
          extraConfig = ''
            tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
            reverse_proxy localhost:${toString config.services.sunshine.settings.port}
          '';
        };
      };
    };
  };
}
