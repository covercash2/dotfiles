# Immich photo management

{ config, lib, pkgs, ... }:

{

  services = {
    immich = {
      enable = true;

      port = 2283;

      # configure GPU acceleration for NN indexing
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };

    postgresql = {
      extensions = pkgs: with pkgs; [ pgvector ];
      ensureUsers = [
        {
          name = "immich";
          ensureDBOwnership = true;
          ensureClauses = {
            createdb = true;
            superuser = false;
          };
        }
      ];
    };
  };
}
