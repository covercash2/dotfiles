{ pkgs, ... }:

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
      ];
      ensureDatabases = [ "chrash" ];
      authentication = pkgs.lib.mkOverride 10 ''
        ## allow local to connect
        #type database  DBuser origin-address auth-method
        local all       all                   trust
        local sameuser  all     peer          map=superuser_map
        host  sameuser  all     ::1/128       scram-sha-256
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
}
