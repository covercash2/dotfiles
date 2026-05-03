# NixOS module for the foundry Digital Ocean VPS
{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "foundry";

  # Tailscale exit node — enables IP forwarding and advertises this droplet
  # as an exit node. Must also be approved in the Tailscale admin console.
  services.tailscale.useRoutingFeatures = "server";

  # NETWORKING: static IP via systemd-networkd.
  #
  # DO assigns a fixed public IP — no need for DHCP. Using static config removes
  # the dependency on DO's DHCP server responding correctly to systemd-networkd
  # (dhcpcd got an IP but dropped the default route on NixOS config switches;
  # systemd-networkd's DHCP client didn't get an IP at all on this droplet).
  #
  # Network details from the DO dashboard:
  #   IP:      45.55.44.173/19  (netmask 255.255.224.0)
  #   Gateway: 45.55.32.1
  #
  # See: https://wiki.nixos.org/wiki/Systemd/networkd
  #      https://docs.digitalocean.com/support/how-do-i-debug-my-droplets-network-configuration/
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."10-ens3" = {
      matchConfig.Name = "ens3";
      networkConfig = {
        Address = "45.55.44.173/19";
        Gateway = "45.55.32.1";
        DNS = "8.8.8.8";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  users.users.root.initialPassword = "foundry";
  users.users.chrash.initialPassword = "foundry";

  security.sudo.wheelNeedsPassword = false;

  # trust the homelab shared CA so green's services work without cert errors
  security.pki.certificates = [ (builtins.readFile ../certs/ca.pem) ];

  environment.systemPackages = with pkgs; [
    git
    ghostty.terminfo # xterm-ghostty terminal type for SSH sessions
    vim
  ];
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers = {
      # prometheus exporter for system info
      node_exporter = {
        image = "quay.io/prometheus/node-exporter:latest";
        volumes = [ "/:/host:ro,rslave" ];
        pull = "newer";
        extraOptions = [ "--network=host" "--pid=host" ];
        cmd = [ "--path.rootfs=/host" ];
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      9100 # node_exporter for prometheus system resource metrics
    ];
  };
}
