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
        #type database  DBuser origin-address auth-method
        local all       all                   trust
        local sameuser  all     peer          map=superuser_map
        host  sameuser  all     ::1/128       scram-sha-256
        host  green     green   127.0.0.1/32  scram-sha-256
        host  green     green   ::1/128       scram-sha-256
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
