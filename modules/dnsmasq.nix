# Internal DNS zone for *.chrash.net
# Runs on port 5354; AdGuard forwards *.chrash.net queries here
# (modules/adguard.nix). Deliberately not 5353 — that's the IANA mDNS port,
# and otbr (modules/thread.nix) runs its own mDNS responder on the host
# network namespace for Thread/Matter discovery.
#
# also listens on green's Tailscale IP, not just loopback:
# adguardhome-sync (modules/adguardhome-sync.nix) copies this whole AdGuard config
# onto foundry's replica every 30 minutes,
# including the upstream_dns forward to
# this dnsmasq.
# Add a new host by appending an address line.
{ ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5354;
      listen-address = [
        "127.0.0.1"
        "100.64.163.18"
      ];
      bind-interfaces = true;
      no-hosts = true;
      no-resolv = true;

      # Mark the zones authoritative-local.
      local = [
        "/green.chrash.net/"
        "/hoss.chrash.net/"
        "/foundry.chrash.net/"
      ];

      # Each entry matches the bare host domain and all subdomains.
      address = [
        "/green.chrash.net/100.64.163.18"
        "/hoss.chrash.net/100.74.58.55"
        "/foundry.chrash.net/100.127.25.99"
      ];
    };
  };

  # dnsmasq binds green's Tailscale IP, which doesn't exist until tailscaled
  # has brought tailscale0 up.
  systemd.services.dnsmasq = {
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    startLimitIntervalSec = 0;
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Reachable from foundry over Tailscale (see the listen-address note
  # above) but from nowhere else.
  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [ 5354 ];
}
