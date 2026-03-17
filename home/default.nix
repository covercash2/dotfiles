# Base home-manager module — imports all program sub-modules.
# Receives `hostname` via extraSpecialArgs for host-specific overrides.
{ pkgs, hostname, ... }:

{
  imports = [
    ./packages.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/atuin.nix
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
  home.username = "chrash";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/chrash" else "/home/chrash";

  # Let home-manager manage itself when used standalone (macOS).
  programs.home-manager.enable = true;

  # Minimum state version — do not change after first activation.
  home.stateVersion = "24.05";
}
