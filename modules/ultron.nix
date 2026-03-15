# Ultron service config

{ ... }:

{
  services.ultron = {
    enable = true;

    secretsFile = "/mnt/space/ultron/secrets";
    port = 9091;
    rustLog = "info,ultron=debug,ultron_core=debug,ultron_discord=debug";
  };
}
