# Hermes Agent — Nous Research agent runtime.
# https://hermes-agent.nousresearch.com/docs/user-guide/configuration
{ config, ... }:
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # DISCORD_BOT_TOKEN presence alone connects the Discord platform; see
    # modules/hoss-sops.nix for the secret.
    environmentFiles = [ config.sops.templates."hermes-discord-env".path ];

    settings = {
      model = {
        provider = "ollama";
        default = "qwen3.5:9b";
      };

      providers.ollama.base_url = "http://localhost:11434/v1";

      # don't let Hermes manage ollama; it's already a system service here.
      local_runtime.enabled = false;
    };
  };
}
