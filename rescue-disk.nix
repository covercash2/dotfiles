# a rescue disk configuration for system recovery scenarios
# builds a bootable ISO image with essential recovery tools
# https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
#
# BUILDING
#   Must be built on x86_64-linux — cross-compilation from macOS (aarch64-darwin)
#   is not supported. Build on green or hoss:
#
#     just build_rescue
#     # or directly:
#     nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage
#
#   To build for a specific host from another machine:
#     just --set hostname hoss build
#
# WRITING TO DISK
#   Use the `flash rescue-disk` nushell command from nuenv/disk.nu:
#     flash rescue-disk /dev/sdX
#
#   This lists available block devices, prompts for confirmation, and runs dd.
#   Alternatively, run dd directly:
#     sudo dd if=result/iso/rescue-disk.iso of=/dev/sdX bs=4M status=progress conv=fsync
#
#   Replace /dev/sdX with the target device (e.g. /dev/sdb). Make sure it is
#   the USB drive and not a system disk.
#
# USAGE
#   Boots as user `nixos` (autologin). The getty help text explains how to
#   switch to `chrash` for the full home-manager environment:
#     su - chrash    (password: rescue)
#   `chrash` has passwordless sudo via the wheel group.

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

  nixpkgs.config.allowUnfree = true;

  # tools available to all users (including root)
  # user-specific tools come from home-manager for the chrash user
  environment.systemPackages = with pkgs; [
    git
    nushell # root's shell
    pciutils
    uv # python package manager
    vim # simple fallback editor
    wget
    unzip
    zip
  ];

  # getty help line displays on the terminal even with autologin,
  # unlike /etc/motd which is bypassed by PAM-less autologin sessions
  services.getty.helpLine = ''

    ┌─────────────────────────────────────────────────┐
    │              NixOS Rescue Disk                  │
    │                                                 │
    │  Logged in as nixos (limited environment).      │
    │                                                 │
    │  For the full terminal environment              │
    │  (neovim, zellij, dotfiles, LSPs), run:         │
    │                                                 │
    │    su - chrash    (password: rescue)            │
    └─────────────────────────────────────────────────┘
  '';

  # root uses nushell for a consistent experience
  users.users.root = {
    shell = pkgs.nushell;
    initialPassword = "rescue";
  };

  # chrash user — home-manager provides the full terminal environment
  users.users.chrash = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.nushell;
    initialPassword = "rescue";
  };

  security.sudo.wheelNeedsPassword = false;

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
}
