# Runs green on hoss instead of green, connecting to the same Postgres
# database (still hosted on green) over Tailscale. See modules/green.nix
# for the primary instance and modules/postgres.nix for the pg_hba/firewall
# rules that let this reach it. Off by default — flip `enable` on when
# actually needed.

{ config, ... }:

{
  services.green = {
    enable = false;

    port = 47336;
    caPath = config.services.mkcert-shared.caPath;

    auth = {
      rpId = "chrash.net";
      rpOrigin = "https://green.hoss.chrash.net";
      # Plaintext dbUrl intentionally omitted — injected at runtime via
      # EnvironmentFile (GREEN_DB_URL) rendered by sops-nix, pointed at
      # green's Postgres over Tailscale (modules/hoss-sops.nix).
      dbUrl = "";
      dbUrlFile = config.sops.templates."green-env".path;
      adminUsers = [ "chrash" ];
    };
  };

  services.caddy.virtualHosts."green.hoss.chrash.net" = {
    extraConfig = ''
      tls ${config.services.mkcert-shared.certPath} ${config.services.mkcert-shared.keyPath}
      reverse_proxy localhost:${toString config.services.green.port}
    '';
  };
}
