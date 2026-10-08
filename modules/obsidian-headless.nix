# Headless Obsidian + Dataview + Local REST API/MCP, synced from a GitHub
# vault repo. Gives Hermes (or any other MCP client) note read/write and
# Dataview query access without depending on any interactive user's home
# directory — see the plan this was built from for the full rationale.
#
# `.obsidian/` (plugins, settings) is gitignored in a typical Obsidian vault
# repo, so a fresh clone has none of it. This module provisions the whole
# tree itself: Dataview and "Local REST API with MCP" (pinned releases,
# fetched by Nix), plus our own small extension plugin
# (../obsidian-dataview-mcp-extension) that bridges Dataview's query API into
# the REST API plugin's built-in MCP server, since that plugin has no native
# Dataview support.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.obsidian-headless;
  vaultDir = "${cfg.stateDir}/vault";
  homeDir = "${cfg.stateDir}/home";
  obsidianConfigDir = "${vaultDir}/.obsidian";

  # Fetched as individual release assets rather than a single zip: Dataview
  # and Local REST API both publish main.js/manifest.json/styles.css as
  # separate release assets, not an archive.
  fetchPluginFile =
    { repo, tag, file, hash }:
    pkgs.fetchurl {
      url = "https://github.com/${repo}/releases/download/${tag}/${file}";
      inherit hash;
    };

  dataviewTag = "0.5.70";
  dataviewFiles = {
    "main.js" = fetchPluginFile {
      repo = "blacksmithgu/obsidian-dataview";
      tag = dataviewTag;
      file = "main.js";
      hash = "sha256-a7HPcBCvrYMOc1dfyg4r+9MnnFYuPZ0k8tL0UWHrfQA=";
    };
    "manifest.json" = fetchPluginFile {
      repo = "blacksmithgu/obsidian-dataview";
      tag = dataviewTag;
      file = "manifest.json";
      hash = "sha256-kjXbRxEtqBuFWRx57LmuJXTl5yIHBW6XZHL5BhYoYYU=";
    };
    "styles.css" = fetchPluginFile {
      repo = "blacksmithgu/obsidian-dataview";
      tag = dataviewTag;
      file = "styles.css";
      hash = "sha256-MwbdkDLgD5ibpyM6N/0lW8TT9DQM7mYXYulS8/aqHek=";
    };
  };

  localRestApiTag = "5.4.0";
  localRestApiFiles = {
    "main.js" = fetchPluginFile {
      repo = "coddingtonbear/obsidian-local-rest-api";
      tag = localRestApiTag;
      file = "main.js";
      hash = "sha256-FDKhVUOpJxIlJOTqGVGqwcudDteEptSDbxx3Hqdrdn8=";
    };
    "manifest.json" = fetchPluginFile {
      repo = "coddingtonbear/obsidian-local-rest-api";
      tag = localRestApiTag;
      file = "manifest.json";
      hash = "sha256-UPylzI6tyilr5G+prRHBR4m55f3fGP4Fj2vELlNTcqY=";
    };
    "styles.css" = fetchPluginFile {
      repo = "coddingtonbear/obsidian-local-rest-api";
      tag = localRestApiTag;
      file = "styles.css";
      hash = "sha256-GZVt6vTRQUI4H4H9+SyugkH9CqCKGjpUZLDQB7rhkk0=";
    };
  };

  ourExtension = pkgs.callPackage ./obsidian-dataview-mcp-extension { };

  obsidianPkg = pkgs.obsidian.override {
    commandLineArgs = "--disable-gpu --disable-software-rasterizer --no-sandbox";
  };

  installPluginFiles =
    id: files:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: ''
        install -D -m 0444 ${src} "$OBS/plugins/${id}/${name}"
      '') files
    );
in
{
  options.services.obsidian-headless = {
    enable = lib.mkEnableOption "headless Obsidian (Dataview + Local REST API/MCP)";

    repoUrl = lib.mkOption {
      type = lib.types.str;
      description = "git URL of the Obsidian vault repo to clone/sync.";
    };

    deployKeyFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Runtime path to a read-write SSH private key for `repoUrl` (e.g. a
        sops-nix secret path). A `str` and not a `path` on purpose — a Nix
        path literal would copy the key into the world-readable store.
      '';
    };

    localRestApiDataJsonFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Runtime path to a pre-rendered data.json for the Local REST API
        plugin (apiKey, bindingHost, ports — see that plugin's
        `LocalRestApiSettings` type). A `str` for the same reason as
        `deployKeyFile` — point this at a `sops.templates.*.path`.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/obsidian-headless";
      description = "Holds the cloned vault, the app's own $HOME, and Xvfb's state.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "obsidian-headless";
      description = "Dedicated system user — deliberately not tied to any interactive user's home.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "obsidian-headless";
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 27123;
      description = "Local REST API plugin's plain-HTTP port (insecurePort) — avoids self-signed-cert trust issues for cross-host MCP clients.";
    };

    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 27124;
    };

    displayNumber = lib.mkOption {
      type = lib.types.int;
      default = 99;
      description = "X display number for the persistent Xvfb instance this module runs.";
    };

    syncIntervalSec = lib.mkOption {
      type = lib.types.int;
      default = 600;
      description = "How often to pull (--ff-only) then push local changes back to repoUrl.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = homeDir;
      createHome = true;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} - -"
      "d ${homeDir} 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services."obsidian-headless-xvfb" = {
      description = "Virtual framebuffer for headless Obsidian";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.xvfb}/bin/Xvfb :${toString cfg.displayNumber} -screen 0 1280x800x24 -nolisten tcp";
        Restart = "always";
        RestartSec = 2;
      };
    };

    systemd.services."obsidian-headless-vault-sync" = {
      description = "Sync the headless Obsidian vault from ${cfg.repoUrl}";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
      };
      environment = {
        HOME = homeDir;
        GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i ${cfg.deployKeyFile} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${cfg.stateDir}/known_hosts";
        GIT_AUTHOR_NAME = "hermes-obsidian-bot";
        GIT_AUTHOR_EMAIL = "hermes-obsidian-bot@noreply.local";
        GIT_COMMITTER_NAME = "hermes-obsidian-bot";
        GIT_COMMITTER_EMAIL = "hermes-obsidian-bot@noreply.local";
      };
      script = ''
        set -euo pipefail
        GIT=${pkgs.git}/bin/git

        if [ ! -d ${vaultDir}/.git ]; then
          "$GIT" clone ${lib.escapeShellArg cfg.repoUrl} ${vaultDir}
          exit 0
        fi

        if ! "$GIT" -C ${vaultDir} pull --ff-only; then
          echo "obsidian-headless-vault-sync: pull did not fast-forward; leaving vault untouched this cycle" >&2
          exit 0
        fi

        if [ -n "$("$GIT" -C ${vaultDir} status --porcelain)" ]; then
          "$GIT" -C ${vaultDir} add -A
          "$GIT" -C ${vaultDir} commit -m "hermes: automated vault sync $(date -Iseconds)"
          if ! "$GIT" -C ${vaultDir} push; then
            echo "obsidian-headless-vault-sync: push failed; will retry next cycle" >&2
          fi
        fi
      '';
    };

    systemd.timers."obsidian-headless-vault-sync" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "${toString cfg.syncIntervalSec}s";
      };
    };

    systemd.services."obsidian-headless-plugins-setup" = {
      description = "Provision .obsidian/ plugins for headless Obsidian";
      after = [ "obsidian-headless-vault-sync.service" ];
      requires = [ "obsidian-headless-vault-sync.service" ];
      before = [ "obsidian-headless.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        set -euo pipefail
        OBS=${obsidianConfigDir}
        mkdir -p "$OBS/plugins"

        printf '%s' '["dataview","obsidian-local-rest-api","obsidian-dataview-mcp-extension"]' > "$OBS/community-plugins.json"

        ${installPluginFiles "dataview" dataviewFiles}
        ${installPluginFiles "obsidian-local-rest-api" localRestApiFiles}
        install -D -m 0444 ${ourExtension}/main.js "$OBS/plugins/obsidian-dataview-mcp-extension/main.js"
        install -D -m 0444 ${ourExtension}/manifest.json "$OBS/plugins/obsidian-dataview-mcp-extension/manifest.json"

        install -D -m 0400 ${cfg.localRestApiDataJsonFile} "$OBS/plugins/obsidian-local-rest-api/data.json"

        mkdir -p ${homeDir}/.config/obsidian
        printf '%s' '{"vaults":{"0000000000000001":{"path":"${vaultDir}","ts":1,"open":true}}}' > ${homeDir}/.config/obsidian/obsidian.json
      '';
    };

    systemd.services."obsidian-headless" = {
      description = "Headless Obsidian (Dataview + Local REST API/MCP)";
      wantedBy = [ "multi-user.target" ];
      after = [
        "obsidian-headless-xvfb.service"
        "obsidian-headless-plugins-setup.service"
        "network-online.target"
      ];
      requires = [
        "obsidian-headless-xvfb.service"
        "obsidian-headless-plugins-setup.service"
      ];
      wants = [ "network-online.target" ];
      environment = {
        DISPLAY = ":${toString cfg.displayNumber}";
        HOME = homeDir;
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        # Electron's Singleton{Lock,Socket,Cookie} in the userData dir block
        # the next launch after an ungraceful stop — clean them up first.
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f ${homeDir}/.config/obsidian/SingletonLock ${homeDir}/.config/obsidian/SingletonSocket ${homeDir}/.config/obsidian/SingletonCookie";
        ExecStart = "${obsidianPkg}/bin/obsidian";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
