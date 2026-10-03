# Hermes Agent — Nous Research agent runtime.
# https://hermes-agent.nousresearch.com/docs/user-guide/configuration
{ config, lib, pkgs, ... }:
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # see modules/hoss-sops.nix for the secrets.
    environmentFiles = [
      # DISCORD_BOT_TOKEN presence alone connects the Discord platform.
      config.sops.templates."hermes-discord-env".path
      # HASS_TOKEN presence alone activates the homeassistant toolset.
      config.sops.templates."hermes-hass-env".path
      # GH_TOKEN authenticates gh beyond unauthenticated public reads.
      config.sops.templates."hermes-gh-env".path
      # GMAIL_TOKEN_PATH points at the gmail.readonly OAuth token.
      config.sops.templates."hermes-gmail-env".path
    ];

    extraPackages = with pkgs; [
      gh
      jq
      python314
      python314Packages.google-auth
      python314Packages.google-auth-oauthlib
      python314Packages.google-api-python-client
    ];

    settings = {
      model = {
        provider = "ollama";
        default = "qwen3.5:27b";
        # must match ollama's actual window, not the model's trained max
        # (which is what ollama's /api/show reports)
        context_length = lib.toInt config.services.ollama.environmentVariables.OLLAMA_CONTEXT_LENGTH;
      };

      providers.ollama = {
        base_url = "http://localhost:11434/v1";
        # backstop: qwen3.5:27b can get stuck self-verifying an exact
        # count/length target in the prompt ("write N words") and never
        # naturally stop — reproduced live, ran to 8,573 tokens unbounded.
        extra_body.max_tokens = 8192;
      };

      # don't let Hermes manage ollama; it's already a system service here.
      local_runtime.enabled = false;

      # user plugins are opt-in; see modules/hermes-plugins/.
      plugins.enabled = [ "gmail" ];
    };
  };

  # Drop-in plugins live under $HERMES_HOME/plugins/<name>/ (source in
  # ../hermes-plugins/ — not Nix-specific, so it's not under modules/). L+
  # re-links on every activation, so edits to the plugin just need a
  # `hermes-agent` restart, not a copy step.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hermes/.hermes/plugins/gmail - - - - ${../hermes-plugins/gmail}"
  ];
}
