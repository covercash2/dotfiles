# a rescue disk configuration for system recovery scenarios
# builds a bootable ISO image with essential recovery tools
# https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
# `nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage`

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    # use the minimal installer as a base for the ISO image
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # set a descriptive label for the generated ISO
  isoImage.isoName = "rescue-disk.iso";

  # essential tools for system recovery
  environment.systemPackages = with pkgs; [
    bat # cat but better
    cyme # better lsusb
    dust # like du but Rust
    fd # faster alternative to find
    git # version control
    jujutsu # version control
    most # pager
    neovim
    nushell
    pciutils
    ripgrep # faster grep
    unzip
    uv # python package manager
    vim # simple text editor
    wget
    zellij # terminal multiplexer
    zip
  ];

  # enable SSH for remote rescue operations
  # note: root login and password authentication are enabled here
  # to allow access during recovery when keys may not be available
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # set a default root password so SSH login works on the rescue disk
  # WARNING: change this before use in any sensitive environment
  users.users.root.initialPassword = "rescue";
}
