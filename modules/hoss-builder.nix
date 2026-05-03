# Configures hoss as a trusted Nix build machine.
# The signing key lets other hosts accept store paths built here
# without --no-check-sigs.
#
# To bootstrap:
#   1. On hoss, generate the key:
#      sudo nix-store --generate-binary-cache-key hoss.chrash.net \
#        /tmp/nix-signing-key.sec /tmp/nix-signing-key.pub
#   2. Create secrets/hoss.yaml:
#      sops secrets/hoss.yaml
#      # add: nix_signing_key: <contents of /tmp/nix-signing-key.sec>
#   3. Add the public key (/tmp/nix-signing-key.pub) to
#      extra-trusted-public-keys in configuration.nix.

{ config, ... }:

{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.nix_signing_key = {
      sopsFile = ../secrets/hoss.yaml;
      mode = "0400";
    };
  };

  nix.settings.secret-key-files = [ config.sops.secrets.nix_signing_key.path ];
}
