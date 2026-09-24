# Hermes Agent — Nous Research agent runtime.
# https://hermes-agent.nousresearch.com/docs/user-guide/configuration
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

      # don't let Hermes manage ollama; it's already a system service here.
      local_runtime.enabled = false;
    };
  };
}
