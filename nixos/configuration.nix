# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    extraOptions = ''
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [
    "nvidia"
    "nvidia-drm"
    "nvidia-uvm"
  ];

  # recommended for PipeWire: https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;

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
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    # this is used to enable video drivers,
    # even though X isn't used in this config
    xserver.videoDrivers = [ "nvidia" ];
    displayManager.enable = false;

    # Enable sound.
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.nushell;
    users.chrash = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "networkmanager" # allow wifi connections
      ];
      home = "/home/chrash";
      useDefaultShell = true;
      packages = with pkgs; [
        asdf-vm # toolchain management
        atuin # sync shell autocomplete across machines
        bitwarden
        bitwarden-cli
        carapace # command line completion
        chezmoi # dotfiles manager
        cyme # lsusb replacement in Rust
        dig # domain name server
        discord
        direnv # loads .envrc for dev environments
        delta # diff viewer for git
        dust # like du but Rust
        ethtool # network tool
        fastfetch # neofetch replacement
        firefox
        gcc
        ghostty # terminal emulator
        grim # Wayland image grabber
        helvum # PipeWire patch bay

        just
        kitty
        libgcc
        lshw
        lua-language-server
        neovim
        nil # nix lsp
        pavucontrol # volume control for pulse audio

        ripgrep
        slurp # select a region of the screen in Wayland
        starship
        typos # find typos in source code projects
        typos-lsp
        tree
        usbutils # lsusb etc
        wezterm
        wl-clipboard
        wofi # runner a la rofi, Spotlight
        xdg-utils # e.g. xdg-open
        zellij # terminal multiplexer
        zoxide # cd replacement with a memory
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bat # cat but better
    git
    most # pager
    neovim
    nushell
    pciutils
    uv # python package manager
    wget
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.fira-code
    fira-code-symbols
  ];

  programs = {
    thunar.enable = true;
  };

  xdg = {
    # enable different desktop integration features
    # https://github.com/flatpak/xdg-desktop-portal
    portal = {
      enable = true;
    };
    mime = {
      defaultApplications = {
        "inode/directory" = "thunar.desktop";

        "default-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      };
    };
    terminal-exec.enable = true;
  };

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
