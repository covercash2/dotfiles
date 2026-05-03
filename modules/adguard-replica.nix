# AdGuard Home replica for foundry — config pushed by adguardhome-sync on green.
#
# After first deploy, complete the setup wizard at http://<foundry-tailscale-ip>:3000,
# then add credentials to secrets/green.yaml so the sync service can authenticate.
{ ... }:

{
  services.adguardhome = {
    enable = true;
    openFirewall = false; # restrict to Tailscale only (see firewall below)
    mutableSettings = true; # adguardhome-sync owns the running config after initial boot
    port = 3000;
    settings = {
      dns = {
        # Baseline config — after the first sync these are overwritten by green's settings
        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "1.1.1.1"
          "1.0.0.1"
          "https://dns.google/dns-query"
          "8.8.8.8"
          "8.8.4.4"
          "https://dns.quad9.net/dns-query"
          "9.9.9.9"
          "149.112.112.112"
        ];
        fallback_dns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
        bootstrap_dns = [ "1.1.1.1" "8.8.8.8" ];
        cache_size = 134217728;
        cache_ttl_min = 60;
        cache_ttl_max = 86400;
        cache_optimistic = true;
        upstream_mode = "load_balance";
        fastest_timeout = "1s";
        enable_dnssec = true;
        edns_client_subnet.enabled = false;
        ratelimit = 20;
        use_private_ptr_resolvers = true;
        rewrites = [
          {
            domain = "*.green.chrash.net";
            answer = "100.64.163.18"; # green's Tailscale IP
          }
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search.enabled = false;
      };
    };
  };

  # DNS (53) and admin/sync (3000) accessible only from the Tailscale interface.
  # Never expose port 53 publicly on a VPS.
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
