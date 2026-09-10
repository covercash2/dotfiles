# Hermes Agent — Nous Research agent runtime, hosted on hoss (RTX 4090 box).
# https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
# https://hermes-agent.nousresearch.com/docs/user-guide/configuration
#
# Points at hoss's local ollama (modules/hoss.nix -> services.ollama) via its
# OpenAI-compatible endpoint, so the experiment costs nothing and needs no API
# key. To move to a hosted provider later, add it under `settings.providers`
# with an api_key fed through environmentFiles + sops (see the green-env
# template in modules/sops.nix for the pattern) and repoint `settings.model`.
#
# config shape matters: Hermes does NOT split a flat `model = "ollama/qwen3.5:9b"`
# string into a provider (verified against hermes-agent 0.21.1 —
# hermes_cli/runtime_provider._get_model_config). the provider must be named
# explicitly under `model.provider`, with the endpoint under
# `providers.<name>.base_url`. tested end to end: chat + terminal tool calls
# both work against local ollama with this config.
{ ... }:
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    settings = {
      model = {
        provider = "ollama";
        default = "qwen3.5:9b";
      };

      providers.ollama.base_url = "http://localhost:11434/v1";

      # ollama already runs as a system service here — don't let Hermes manage it.
      local_runtime.enabled = false;
    };
  };
}
