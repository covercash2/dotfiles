# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["nvidia" "nvidia-drm" "nvidia-uvm"];

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

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # this is used to enable video drivers,
  # even though X isn't used in this config
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.enable = false;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chrash = {
    isNormalUser = true;
    extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "networkmanager" # allow wifi connections
    ];
    shell = pkgs.nushell;
    packages = with pkgs; [
      asdf-vm # toolchain management
      bitwarden
      carapace # command line completion
      chezmoi # dotfiles manager
      discord
      fastfetch # neofetch replacement
      firefox
      gcc
      grim # Wayland image grabber

      kitty
      libgcc
      lshw
      lua-language-server
      neovim
      nil # nix lsp

      slurp # select a region of the screen in Wayland
      starship
      tree
      wezterm
      wl-clipboard
      wofi # runner a la rofi, Spotlight
      zellij # terminal multiplexer
      zoxide # cd replacement with a memory
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    nushell
    ov
    pciutils
    wget
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];

  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables.EDITOR = "nvim";
  environment.variables.PAGER = "ov";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

