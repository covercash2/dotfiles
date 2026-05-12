# Internal DNS zone for *.chrash.net
# Runs on port 5353 (localhost only); AdGuard forwards *.chrash.net queries here.
# Add a new host by appending an address line — no AdGuard changes needed.
{ ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5353;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-hosts = true;
      no-resolv = true;

      # Each entry matches the bare host domain and all subdomains.
      address = [
        "/green.chrash.net/100.64.163.18"
        "/hoss.chrash.net/100.74.58.55"
      ];
    };
  };
}
