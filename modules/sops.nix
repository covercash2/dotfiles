{ config, ... }:
{
  # Decrypt secrets at activation time using the SSH host key.
  # The corresponding age public key is pinned in .sops.yaml.
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.green_db_password = {
      sopsFile = ../secrets/green.yaml;
      owner = "green";
      group = "green";
      mode = "0400";
    };

    secrets.mqtt_password = {
      sopsFile = ../secrets/green.yaml;
      owner = "green";
      group = "green";
      mode = "0400";
    };

    secrets.pgadmin_password = {
      sopsFile = ../secrets/green.yaml;
      owner = "pgadmin";
      mode = "0400";
    };

    secrets.miniflux_admin_password = {
      sopsFile = ../secrets/green.yaml;
      owner = "miniflux";
      group = "miniflux";
      mode = "0400";
    };

    templates."miniflux-credentials" = {
      content = ''
        ADMIN_USERNAME=chrash
        ADMIN_PASSWORD=${config.sops.placeholder.miniflux_admin_password}
      '';
      owner = "miniflux";
      group = "miniflux";
      mode = "0400";
    };

    # Renders an EnvironmentFile that green's systemd unit reads.
    # GREEN_DB_URL overrides db_url from config.toml at runtime so that
    # the credential never appears in the Nix store.
    templates."green-env" = {
      content = ''
        GREEN_DB_URL=postgres://green:${config.sops.placeholder.green_db_password}@localhost:${builtins.toString config.services.postgresql.settings.port}/green
        GREEN_MQTT_PASSWORD=${config.sops.placeholder.mqtt_password}
      '';
      owner = "green";
      group = "green";
      mode = "0400";
    };
  };
}
