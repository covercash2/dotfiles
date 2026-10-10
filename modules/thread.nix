# Thread / Matter support, bridged through the SMLight SLZB-MR1U's second
# radio (EFR32MG21, flashed to "Thread to remote OTBR" mode — see
# modules/zigbee_receiver.nix for the first radio, which still does Zigbee).
#
# The radio exposes a Thread RCP (spinel) service over the network rather
# than a local serial device, so otbr-agent can't talk to it directly — the
# `otbr` container bridges that TCP socket to a local pty via socat
# internally (same mechanism as Home Assistant's official OTBR add-on; see
# https://github.com/home-assistant/addons/tree/master/openthread_border_router).
# Home Assistant here runs as a plain container (modules/homeassistant.nix),
# not HAOS, so the Supervisor add-on itself isn't available — this uses
# denniswitt/homeassistant-otbr, a de-supervisored build of the same add-on
# configured via environment variables instead of bashio/Supervisor options.
#
# matter-server bridges HA's Matter integration to the Thread network via
# the otbr-agent started above.

{ ... }:

let
  # TODO: confirm this is a static reservation on the router — SMLight's web
  # UI (currently showing this as the radio's address) doesn't guarantee it
  # survives a DHCP lease renewal.
  radioAddress = "192.168.2.165";
  radioPort = 6638;
  # From the SLZB-MR1U web UI: Serial Speed reported for the Thread radio.
  baudrate = 460800;
in
{
  virtualisation.oci-containers.containers = {
    otbr = {
      # podman needs a fully-qualified name — unlike docker it won't guess
      # the registry for a bare "user/image" short-name.
      image = "docker.io/denniswitt/homeassistant-otbr:latest";
      pull = "newer";
      autoStart = true;

      environment = {
        NETWORK_DEVICE = "${radioAddress}:${toString radioPort}";
        BAUDRATE = toString baudrate;
        # SMLight's guide has us disable hardware flow control for the
        # network-connected radio.
        FLOW_CONTROL = "0";
        # green's LAN interface — see modules/green.nix.
        BACKBONE_IF = "enp5s0";
        FIREWALL = "1";
        NAT64 = "0";
        OTBR_LOG_LEVEL = "notice";
      };

      volumes = [
        "/mnt/space/otbr/data:/data"
      ];

      # otbr-agent needs to create and manage a wpan0 interface, run its own
      # ip6tables/ipset rules, and do border routing on the host's backbone
      # interface — same privileges Home Assistant's add-on requests
      # (host_network, NET_ADMIN, NET_RAW, IPC_LOCK, /dev/net/tun).
      extraOptions = [
        "--network=host"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--cap-add=IPC_LOCK"
        "--device=/dev/net/tun"
      ];
    };

    matter-server = {
      image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
      pull = "newer";
      autoStart = true;

      volumes = [
        "/mnt/space/matter-server/data:/data"
        "/run/dbus:/run/dbus:ro"
      ];

      # Needs host networking for mDNS discovery of Matter devices, and
      # apparmor disabled per upstream's documented run command.
      extraOptions = [
        "--network=host"
        "--security-opt=apparmor=unconfined"
      ];
    };
  };

  # otbr-agent's border-routing feature forwards IPv6 between the Thread
  # mesh (wpan0) and the LAN (enp5s0) — without this, Thread devices get a
  # mesh-local address but no route out.
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # podman doesn't create bind-mount source directories on the host — unlike
  # zigbee2mqtt (its own NixOS module manages dataDir) or homeassistant (its
  # volume is a system user's home, see modules/homeassistant.nix), nothing
  # else creates these.
  #
  # Owned by chrash:users, matching /mnt/space itself — a root-owned child
  # under chrash's directory trips systemd-tmpfiles' "unsafe path
  # transition" guard (it won't create a root-owned path under a directory
  # it doesn't trust as root) and silently aborts the whole rule batch.
  # The containers run as root anyway, which bypasses file permissions, so
  # there's no functional need for root ownership here.
  systemd.tmpfiles.rules = [
    "d /mnt/space/otbr 0755 chrash users - -"
    "d /mnt/space/otbr/data 0750 chrash users - -"
    "d /mnt/space/matter-server 0755 chrash users - -"
    "d /mnt/space/matter-server/data 0750 chrash users - -"
  ];

  # 8080 = otbr-web UI, 8081 = OpenThread REST API, 5580 = matter-server
  # websocket (consumed by Home Assistant's Matter integration).
  networking.firewall.allowedTCPPorts = [ 8080 8081 5580 ];
}
