# Migrated from dot_config/atuin/config.toml
{ ... }:

{
  programs.atuin = {
    enable = true;
    settings = {
      sync_address = "http://green:8888";
    };
  };
}
