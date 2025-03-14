{ config, lib, pkgs, ... }:

{
  networking.hostName = "hoss";
  nixpkgs.config.cudaSupport = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # enable CUDA in containers
    nvidia-container-toolkit.enable = true;
  };

  services = {
    tailscale.enable = true;
    blueman.enable = true;
    ollama = {
      enable = true;
      user = "ollama";
      models = "/mnt/space/ollama/models";
      home = "/mnt/space/ollama";
      host = "0.0.0.0";
      port = 11434;
      openFirewall = true;
    };
  };

  networking.firewall = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    devenv
    direnv
    zenith-nvidia
  ];

  fileSystems = {
    "/mnt/space" = {
      device = "/dev/disk/by-label/space";
      fsType = "ext4";
    };
  };

  # containers
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers = {
      mistral_rs = {
        image = "ghcr.io/ericlbuehler/mistral.rs:cuda-90-0.4";
        ports = [ "14554:80" ];
        volumes = ["/mnt/space/hfhub"];
        pull = "newer";
        devices = [ "nvidia.com/gpu=all" ];
        cmd = [ "plain" "--model-id" "microsoft/Phi-3.5-MoE-instruct" "-a" "phi3.5moe" ];
      };
      # prometheus exporter for system info
      node_exporter = {
        image = "quay.io/prometheus/node-exporter:latest";
        volumes = ["/:/host:ro,rslave"];
        pull = "newer";
        extraOptions = [ "--network=host" "--pid=host" ];
        cmd = [ "--path.rootfs=/host" ];
      };
    };
  };
}
