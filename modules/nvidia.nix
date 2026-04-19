# Common Nvidia GPU configuration shared by wall-e, green, and hoss.
# Import this module from the host-specific .nix file.
{ config, ... }:

{
  boot.kernelModules = [
    "nvidia"
    "nvidia-drm"
    "nvidia-uvm"
  ];

  # this is used to enable video drivers,
  # even though X isn't used in this config
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;

    # power management options are unstable
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # use the open source kernel module
    open = false;
  };
}
