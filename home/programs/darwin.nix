{ pkgs, lib, ... }:
{
  # Ghostty terminal: manage config, point to Nix-managed nushell
  xdg.configFile."ghostty/config" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      command = ${pkgs.nushell}/bin/nu
    '';
  };
}
