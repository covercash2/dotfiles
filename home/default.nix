# Base home-manager module — imports all program sub-modules.
# Receives `hostname` and `username` via extraSpecialArgs for host-specific overrides.
{ pkgs, lib, hostname, username, ... }:

{
  # Provide a default for extraNuLibDirs so hosts that don't set it in
  # extraSpecialArgs still satisfy the module system's arg resolution.
  # boxer overrides this via extraSpecialArgs.extraNuLibDirs.
  _module.args.extraNuLibDirs = lib.mkDefault [];

  imports = [
    ./packages.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/shells.nix
    ./programs/zellij.nix
    ./programs/neovim.nix
    ./programs/wm.nix
    ./programs/darwin.nix
  ];

  # Miscellaneous dotfiles
  home.file.".ideavimrc".text = ''
    nmap <C-o> :action Back<CR>

    set surround
  '';

  # Link nuenv directory so `overlay use default.nu` in config.nu works
  home.file."nuenv".source = ../nuenv;

  # Required: home-manager needs to know the home directory and username.
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Let home-manager manage itself when used standalone (macOS).
  programs.home-manager.enable = true;

  # Minimum state version — do not change after first activation.
  home.stateVersion = "24.05";
}
