# User packages previously declared under users.users.chrash.packages
# in configuration.nix. Managed here by home-manager.
{ pkgs, lib, withDesktop ? true, ... }:

{
  home.packages = with pkgs; [
    asdf-vm # toolchain management
    bat # better than cat
    bitwarden-cli
    carapace # command line completion
    # claude-code
    dig # domain name server
    direnv # loads .envrc for dev environments
    delta # diff viewer for git
    dust # like du but Rust
    fastfetch # neofetch replacement
    gh # GitHub CLI

    jujutsu
    just
    k9s
    kubectl
    # lua-language-server: via programs.neovim.extraPackages
    # neovim, nil, lua-language-server, typos-lsp installed via programs.neovim in programs/neovim.nix
    nix-update # used to bump versions in nix files
    obsidian # note taking software
    opencode

    nufmt # nushell formatter
    # nushellPlugins.net # list net interfaces: `$ net`
    nushellPlugins.skim # fuzzy finder for everything: `$ ps | sk`
    nushellPlugins.highlight # highlight raw text: `$ open --raw data.json | highlight`
    nushellPlugins.semver

    opencode
    ripgrep
    starship
    typos # find typos in source code projects
    # typos-lsp: via programs.neovim.extraPackages
    tree
    xdg-utils # e.g. xdg-open
    yt-dlp
    zellij # terminal multiplexer
    zoxide # cd replacement with a memory
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    cyme # lsusb replacement in Rust
    ethtool # network tool
    gcc
    libgcc
    lshw
    usbutils # lsusb etc
  ] ++ lib.optionals (pkgs.stdenv.isLinux && withDesktop) [
    bitwarden-desktop
    discord
    firefox
    ghostty # terminal emulator (macOS users run the native app)
    grim # Wayland image grabber
    pavucontrol # volume control for pulse audio
    slurp # select a region of the screen in Wayland
    wl-clipboard
    wofi # runner a la rofi, Spotlight
  ];
}
