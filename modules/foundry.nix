# NixOS module for the foundry Digital Ocean VPS
{ ... }:

{
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
      22   # SSH
      9100 # node_exporter for prometheus system resource metrics
    ];
  };
}
