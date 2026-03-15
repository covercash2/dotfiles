{ pkgs, ... }:

{
  systemd.services.lspmux = {
    enable = true;

    # run a systemd service for lspmux
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    unitConfig = {
      Description = "LSP Multiplexer to cache servers for Neovim or other LSP clients";
    };

    path = [ pkgs.ra-multiplex ];

    script = "lspmux serve --config /mnt/space/lspmux/config.yaml";

    serviceConfig = {
      # recommended for long-running services
      Type = "exec";
      Restart = "on-success";
      User = "lspmux";
      Group = "lspmux";
      WorkingDirectory = "/mnt/space/lspmux";
    };

    wantedBy = [ "multi-user.target" ];
  };

  users = {
    users.lspmux = {
      group = "lspmux";
      isSystemUser = true;
      createHome = false;
      home = "/mnt/space/lspmux";
      description = "lspmux user";
      packages = with pkgs; [
        lspmux
      ];
    };
    groups.lspmux = { };
  };
}
