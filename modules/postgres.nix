{ pkgs, config, ... }:

{
  services = {
    postgresql = {
      enable = true;
      enableTCPIP = true;
      dataDir = "/mnt/space/postgres";
      settings = {
        ssl = true;
        port = 5432; # default port echoed here for docs
      };
      ensureUsers = [
        {
          name = "chrash";
          ensureDBOwnership = true;
          ensureClauses = {
            createdb = true;
            superuser = true;
          };
        }
        {
          name = "green";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
      ensureDatabases = [ "chrash" "green" ];
      authentication = pkgs.lib.mkOverride 10 ''
        ## allow local to connect
        #type database  DBuser origin-address  auth-method
        local all       all                    trust
        local sameuser  all     peer           map=superuser_map
        host  sameuser  all     ::1/128         scram-sha-256
        host  green     green   127.0.0.1/32    scram-sha-256
        host  green     green   ::1/128         scram-sha-256

        # hoss running the green service remotely, over Tailscale.
        # This must be the IP, not the hostname: Postgres's hostname-based
        # pg_hba matching requires a *reverse* DNS lookup on the connecting
        # IP (not just a forward lookup of the pg_hba entry), and green's
        # resolver doesn't forward the Tailscale CGNAT reverse zone
        # (100.64.0.0/10) to Tailscale's DNS — only the forward
        # faun-truck.ts.net zone. Confirmed via:
        #   getent hosts 100.74.58.55   # fails on green
        #   getent hosts hoss.faun-truck.ts.net   # succeeds
        # If hoss's Tailscale IP ever changes (`tailscale status` on hoss),
        # update this to match.
        host  green     green   100.74.58.55/32  scram-sha-256
      '';
      identMap = ''
        # ArbitraryMapName systemUser DBUser
        superuser_map      root       postgres
        superuser_map      postgres   postgres
        # Let other names login as themselves
        superuser_map      /^(.*)$    \1
      '';
    };
  };

  users.users.postgres = {
    isSystemUser = true;
    home = "/mnt/space/postgres";
    description = "PostgreSQL server user";
  };

  # Postgres is reachable cross-host only over Tailscale (see the pg_hba
  # rule above) — not opened on the general LAN-facing firewall.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.postgresql.settings.port
  ];

  # Automatically refresh collation versions after glibc upgrades to prevent
  # postgresql-setup.service from failing with a collation version mismatch.
  systemd.services.postgresql-refresh-collation = {
    description = "Refresh PostgreSQL collation versions after glibc upgrade";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    before = [ "postgresql-setup.service" ];
    wantedBy = [ "postgresql-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      for db in $(${config.services.postgresql.package}/bin/psql -tA -c "SELECT datname FROM pg_database;"); do
        ${config.services.postgresql.package}/bin/psql -d "$db" -c "ALTER DATABASE \"$db\" REFRESH COLLATION VERSION;" 2>/dev/null || true
      done
    '';
  };
}
