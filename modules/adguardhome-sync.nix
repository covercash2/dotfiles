# adguardhome-sync: pushes AdGuard Home config from green (primary) to foundry (replica).
# Runs as a podman container on green with host networking so it can reach:
#   - green's AdGuard at 127.0.0.1:3000
#   - foundry's AdGuard at <foundryTailscaleIp>:3000 over the tailscale0 interface
#
# SETUP STEPS (one-time, before deploying):
# 1. Run `tailscale ip --4` on foundry and set foundryTailscaleIp below.
# 2. Add the following keys to secrets/green.yaml (re-encrypt with: sops secrets/green.yaml):
#      adguardhome_origin_password: <green's AdGuard admin password>
#      adguardhome_replica_password: <foundry's AdGuard admin password>
# 3. After deploying foundry for the first time, visit http://<foundryTailscaleIp>:3000
#    to complete the AdGuard setup wizard and set the admin password.
# 4. Configure Tailscale DNS in the admin console to use both Tailscale IPs as nameservers.

{ config, ... }:

let
  foundryTailscaleIp = "100.127.25.99";

  syncConfigPath = config.sops.templates."adguardhome-sync.yaml".path;
in
{
  sops.secrets.adguardhome_origin_password = {
    sopsFile = ../secrets/green.yaml;
    mode = "0400";
  };

  sops.secrets.adguardhome_replica_password = {
    sopsFile = ../secrets/green.yaml;
    mode = "0400";
  };

  sops.templates."adguardhome-sync.yaml" = {
    content = ''
      cron: "*/30 * * * *"
      runOnStart: true

      origin:
        url: http://127.0.0.1:3000
        username: admin
        password: ${config.sops.placeholder.adguardhome_origin_password}

      replicas:
        - url: http://${foundryTailscaleIp}:3000
          username: admin
          password: ${config.sops.placeholder.adguardhome_replica_password}
    '';
    mode = "0444";
  };

  virtualisation.oci-containers.containers.adguardhome-sync = {
    image = "ghcr.io/bakito/adguardhome-sync:latest";
    pull = "newer";
    # Host networking lets the container reach both localhost:3000 (green's AdGuard)
    # and foundry's Tailscale IP via the host's tailscale0 interface.
    extraOptions = [ "--network=host" ];
    volumes = [
      "${syncConfigPath}:/config/adguardhome-sync.yaml:ro"
    ];
  };
}
