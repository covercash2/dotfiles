{ pkgs, lib, ... }:
{
  # Ghostty terminal: manage config, point to Nix-managed nushell
  xdg.configFile."ghostty/config" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      command = ${pkgs.nushell}/bin/nu
    '';
  };

  # Trust the homelab CA in the user keychain so *.green.chrash.net certs are valid
  home.activation.installHomelabCA = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD /usr/bin/security add-trusted-cert \
        -r trustRoot \
        -k "$HOME/Library/Keychains/login.keychain-db" \
        ${../../certs/ca.pem}
    ''
  );
}
