{ config, lib, ... }:
let
  # green user only exists when services.green.enable is true
  # (modules/hoss-green.nix). fall back to root otherwise — see
  # docs/troubleshooting.md ("every nix build fails...") for why this matters.
  greenOwner = lib.mkIf config.services.green.enable "green";
in
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.ca_key = {
      sopsFile = ../secrets/hoss.yaml;
      mode = "0400";
    };

    # Copy of green's green_db_password, stored in hoss's own secrets file
    # (encrypted only for hoss's key, per the one-file-per-host/single-
    # recipient model in nuenv/sops.nu). Keep it in sync manually if the
    # password ever rotates:
    #   secrets get green_db_password            # run on green
    #   secrets add green_db_password --host hoss # run on hoss
    secrets.green_db_password = {
      sopsFile = ../secrets/hoss.yaml;
      owner = greenOwner;
      group = greenOwner;
      mode = "0400";
    };

    # EnvironmentFile for a green instance on hoss. only meaningful once
    # services.green.enable is true (modules/hoss-green.nix).
    templates."green-env" = {
      content = ''
        GREEN_DB_URL=postgres://green:${config.sops.placeholder.green_db_password}@green.faun-truck.ts.net:5432/green
      '';
      owner = greenOwner;
      group = greenOwner;
      mode = "0400";
    };
  };
}
