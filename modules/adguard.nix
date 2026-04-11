# adguard DNS server

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    # only applies to the admin UI port, not DNS ports
    openFirewall = true;
    mutableSettings = true;
    port = 3000; # the port for the HTTP portal
    settings = {
      dns = {
        upstream_dns = [
          # Cloudflare DNS
          "https://dns.cloudflare.com/dns-query"
          "1.1.1.1"
          "1.0.0.1"
          # Google DNS
          "https://dns.google/dns-query"
          "8.8.8.8"
          "8.8.4.4"
          # Quad9
          "https://dns.quad9.net/dns-query"
          "9.9.9.9"
          "149.112.112.112"
        ];
        fallback_dns = [
          # Cloudflare as primary fallback
          "1.1.1.1"
          "1.0.0.1"
          # Google as secondary fallback
          "8.8.8.8"
          "8.8.4.4"
        ];

        # Bootstrap DNS for resolving DoH/DoT upstream servers
        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        # Performance optimizations
        cache_size = 134217728; # 128MB cache
        cache_ttl_min = 60; # 1 minute minimum TTL
        cache_ttl_max = 86400; # 24 hour maximum TTL
        cache_optimistic = true; # Serve stale cache while updating

        # Load balance between upstream servers for better performance
        upstream_mode = "load_balance";
        fastest_timeout = "1s";

        # Security
        enable_dnssec = true; # Validate DNSSEC signatures
        edns_client_subnet = {
          enabled = false; # Privacy: don't send client subnet to upstreams
        };

        # Rate limiting (20 queries/sec per client - reasonable for home use)
        ratelimit = 20;

        # Use private PTR resolvers for reverse DNS of local addresses
        use_private_ptr_resolvers = true;

        # DNS rewrites for internal domains
        # NOTE: For a more scalable approach, consider setting up a dedicated internal
        # DNS server (dnsmasq/unbound) and using conditional forwarding:
        #   upstream_dns = [ "[/*.green.chrash.net/]192.168.1.1" ... ];
        rewrites = [
          {
            domain = "*.green.chrash.net";
            answer = "100.64.163.18"; # Tailscale IP of this server
          }
        ];
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;

        safe_search = {
          enabled = false;
        };
      };

      filters = lib.imap1 (id: url: {
        enabled = true;
        inherit id url;
      }) [
        # General ad blocking
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"   # AdGuard DNS filter (general ads)
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"   # AdGuard Base filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt"   # AdGuard Mobile Ads filter
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt"   # AdGuard Tracking Protection filter

        # Popular community lists
        "https://easylist.to/easylist/easylist.txt"                              # EasyList (general ads)
        "https://easylist.to/easylist/easyprivacy.txt"                           # EasyPrivacy (tracking)
        "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=0" # Peter Lowe's Ad Server List

        # Security & malware
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"   # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # Malicious URL Blocklist
        "https://urlhaus.abuse.ch/downloads/hostfile/"                           # URLhaus Malware URL Blocklist

        # Annoyances
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_14.txt"  # AdGuard Annoyances filter
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      53 # unsecured DNS
    ];
    allowedUDPPorts = [
      53 # unsecured DNS
    ];
  };
}
