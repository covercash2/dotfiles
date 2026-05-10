# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # 4 jobs × 4 cores each is a reasonable ceiling for all machines.
      # Do NOT set cores = 0 (all cores per job) — with multiple jobs it exhausts memory.
      max-jobs = 4;
      cores = 4;
      extra-substituters = [ "https://devenv.cachix.org" ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hoss.chrash.net:MOydjP63PR69FuIpPoXXBtIWPHk0AVExmifkGPaK1X0="
      ];
      # wheel users can pass --no-check-sigs when copying from trusted local machines
      trusted-users = [ "root" "@wheel" ];
    };
    # Builds run at idle CPU priority — they yield to everything else,
    # keeping the system accessible during heavy updates.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
  };

  # Kill builds before the system freezes.
  # OOMScoreAdjust makes the kernel OOM killer prefer nix build processes over
  # system services. The memory caps (percentage-based, so they scale per machine)
  # ensure the nix-daemon cgroup is sacrificed before RAM is fully exhausted.
  # MemoryHigh starts throttling at 70%; MemoryMax hard-kills at 80%.
  systemd.services.nix-daemon.serviceConfig = {
    OOMScoreAdjust = 500;
    MemoryHigh = "70%";
    MemoryMax = "80%";
  };

  # systemd-oomd acts proactively on memory pressure, well before the kernel
  # OOM killer triggers — preventing the full system freeze that requires a
  # hard reboot to recover from.
  systemd.oomd = {
    enable = true;
    enableSystemSlice = true;
    enableUserServices = true;
  };

  # Without swap, memory exhaustion is a cliff — the kernel has no buffer in
  # which to detect pressure and act. zram gives oomd time to react by
  # providing compressed in-memory swap before the system seizes.
  zramSwap = {
    enable = true;
    memoryPercent = 10;
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader by default.
  # Hosts that use GRUB (e.g. foundry BIOS/KVM) override these in their
  # hardware-configuration.nix by setting systemd-boot.enable = false and
  # grub.enable = true at default priority, which overrides mkDefault.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "ter-v16b";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true; # use xkb.options in tty.
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
      # User packages are now managed by home-manager (see nixos/home/packages.nix)
      packages = [ ];
      openssh.authorizedKeys.keyFiles = [
        (builtins.fetchurl {
          url = "https://github.com/covercash2.keys";
          sha256 = "0d63kky16b3lz048mkdf8l1nf8lp4kx0clh7xn8rwczhkfvvmxh2";
        })
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
    rops
    uv # python package manager
    wget

    unzip
    zip
  ];

  services.tailscale.enable = true;

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
