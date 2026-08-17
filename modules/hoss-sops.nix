{ config, ... }:
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
      owner = "green";
      group = "green";
      mode = "0400";
    };

    # Renders an EnvironmentFile for a green service instance running on
    # hoss, pointing at green's Postgres over Tailscale rather than
    # localhost. Only meaningful once services.green.enable is true here
    # (see modules/hoss-green.nix).
    templates."green-env" = {
      content = ''
        GREEN_DB_URL=postgres://green:${config.sops.placeholder.green_db_password}@green.faun-truck.ts.net:5432/green
      '';
      owner = "green";
      group = "green";
      mode = "0400";
    };
  };
}
