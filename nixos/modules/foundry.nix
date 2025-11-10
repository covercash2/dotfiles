{ pkgs, ... }:

{
  systemd.services.foundryvtt = {
    enable = true;

    # run a systemd service for FoundryVTT
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    unitConfig = {
      Description = "Foundry Virtual Tabletop server";
    };

    path = [ pkgs.nodejs_24 ];

    script = "node ./dist/main.js --dataPath=./data";

    serviceConfig = {
      # recommended for long-running services
      Type = "exec";
      Restart = "on-success";
      User = "foundry";
      Group = "foundry";
      WorkingDirectory = "/mnt/space/foundry";
    };

    wantedBy = [ "multi-user.target" ];
  };

  users = {
    users.foundry = {
      group = "foundry";
      isSystemUser = true;
      home = "/mnt/space/foundry";
      createHome = false;
      description = "Foundry VTT User";
      packages = with pkgs; [
        nodejs_24
      ];
    };
    groups.foundry = { };
  };
}
