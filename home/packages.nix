# User packages previously declared under users.users.chrash.packages
# in configuration.nix. Managed here by home-manager.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    asdf-vm # toolchain management
    atuin # sync shell autocomplete across machines
    bitwarden-desktop
    bitwarden-cli
    carapace # command line completion
    claude-code
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
    gh # GitHub CLI
    grim # Wayland image grabber

    jujutsu
    just
    kitty
    libgcc
    lshw
    # lua-language-server: via programs.neovim.extraPackages
    # neovim, nil, lua-language-server, typos-lsp installed via programs.neovim in programs/neovim.nix
    nix-update # used to bump versions in nix files
    pavucontrol # volume control for pulse audio

    ripgrep
    slurp # select a region of the screen in Wayland
    starship
    typos # find typos in source code projects
    # typos-lsp: via programs.neovim.extraPackages
    tree
    usbutils # lsusb etc
    wezterm
    wl-clipboard
    wofi # runner a la rofi, Spotlight
    xdg-utils # e.g. xdg-open
    zellij # terminal multiplexer
    zoxide # cd replacement with a memory
  ];
}
