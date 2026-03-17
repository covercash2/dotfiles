# User packages previously declared under users.users.chrash.packages
# in configuration.nix. Managed here by home-manager.
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    asdf-vm # toolchain management
    atuin # sync shell autocomplete across machines
    bitwarden-cli
    carapace # command line completion
    claude-code
    dig # domain name server
    direnv # loads .envrc for dev environments
    delta # diff viewer for git
    dust # like du but Rust
    fastfetch # neofetch replacement
    gcc
    gh # GitHub CLI

    jujutsu
    just
    kitty
    # lua-language-server: via programs.neovim.extraPackages
    # neovim, nil, lua-language-server, typos-lsp installed via programs.neovim in programs/neovim.nix
    nix-update # used to bump versions in nix files

    ripgrep
    starship
    typos # find typos in source code projects
    # typos-lsp: via programs.neovim.extraPackages
    tree
    wezterm
    xdg-utils # e.g. xdg-open
    zellij # terminal multiplexer
    zoxide # cd replacement with a memory
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    bitwarden-desktop
    cyme # lsusb replacement in Rust
    discord
    ethtool # network tool
    firefox
    ghostty # terminal emulator (macOS users run the native app)
    grim # Wayland image grabber
    libgcc
    lshw
    pavucontrol # volume control for pulse audio
    slurp # select a region of the screen in Wayland
    usbutils # lsusb etc
    wl-clipboard
    wofi # runner a la rofi, Spotlight
  ];
}
