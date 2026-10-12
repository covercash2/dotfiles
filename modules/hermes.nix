# Hermes Agent — Nous Research agent runtime.
# https://hermes-agent.nousresearch.com/docs/user-guide/configuration
{ config, lib, pkgs, ... }:
let
  # plugin-catalog/homeassistant.yaml pins this exact rev (v2.0.1) — mirror
  # that pin here instead of `hermes plugins install` so the plugin's
  # version is tracked in git like everything else, not installed
  # procedurally onto /var/lib/hermes where a rebuild can't see it.
  homeassistantPlugin = pkgs.fetchFromGitHub {
    owner = "NousResearch";
    repo = "hermes-homeassistant";
    rev = "ba30cb0cf86c52bdb5cde98974bc062e97966529";
    hash = "sha256-Pg4smvkiVpmcmUola0rziMBfq5V7UjzX8864Dem76pI=";
  };
in
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    # see modules/hoss-sops.nix for the secrets.
    environmentFiles = [
      # DISCORD_BOT_TOKEN presence alone connects the Discord platform.
      config.sops.templates."hermes-discord-env".path
      # HASS_TOKEN: required by the homeassistant plugin below (formerly a
      # built-in toolset gated on this var alone; now a separate plugin that
      # still reads the same env var).
      config.sops.templates."hermes-hass-env".path
      # GH_TOKEN authenticates gh beyond unauthenticated public reads.
      config.sops.templates."hermes-gh-env".path
      # GMAIL_TOKEN_PATH points at the gmail.readonly OAuth token.
      config.sops.templates."hermes-gmail-env".path
      # OBSIDIAN_REST_API_KEY is resolved into mcpServers.obsidian-vault's
      # header below via hermes's own ${VAR} interpolation (see
      # tools/mcp_tool_config.py upstream) — NOT a Nix-time substitution.
      config.sops.templates."hermes-obsidian-env".path
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

      # user plugins are opt-in; see modules/hermes-plugins/ (gmail, ours)
      # and the catalog pin above (homeassistant, upstream).
      plugins.enabled = [ "gmail" "homeassistant" ];
    };

    # headless Obsidian + Dataview, served over MCP by the Local REST API
    # plugin itself (/mcp/) — see modules/obsidian-headless.nix on green.
    # Plain HTTP (not the plugin's self-signed-HTTPS port) since this is a
    # cross-host call over Tailscale; the bearer token is the security
    # boundary, same posture as everything else exposed that way in this repo.
    mcpServers.obsidian-vault = {
      url = "http://green.faun-truck.ts.net:27123/mcp/";
      # literal ${...} — hermes resolves this itself at runtime from its own
      # .env (see hermes-obsidian-env below), not a Nix-time substitution.
      headers.Authorization = "Bearer \${OBSIDIAN_REST_API_KEY}";
    };
  };

  # Drop-in plugins live under $HERMES_HOME/plugins/<name>/ (source in
  # ../hermes-plugins/ — not Nix-specific, so it's not under modules/). L+
  # re-links on every activation, so edits to the plugin just need a
  # `hermes-agent` restart, not a copy step.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hermes/.hermes/plugins/gmail - - - - ${../hermes-plugins/gmail}"
    "L+ /var/lib/hermes/.hermes/plugins/homeassistant - - - - ${homeassistantPlugin}"
  ];
}
