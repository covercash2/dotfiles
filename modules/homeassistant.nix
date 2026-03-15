{
  ...
}:

{
  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      pull = "newer";

      autoStart = true;

      # user = "homeassistant";
      # login.username = "homeassistant";
      # podman.user = "homeassistant";
      privileged = true;

      extraOptions = [
        "--network=host"
      ];

      volumes = [
        "/mnt/space/homeassistant/config:/config"
        # "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/rundbus:ro"
      ];
    };
  };

  users.users.homeassistant = {
    isSystemUser = true;
    description = "Home Assistant user";
    group = "homeassistant";
    extraGroups = [ "iot" ];
    home = "/mnt/space/homeassistant";
    createHome = true;
    # this allows systemd services for the homeassistant user to persist even after logout (needed for container runtime or other related services)
    linger = true;
    # totally flying blind. this is apparently a container security feature
    subUidRanges = [
      {
        count = 100000;
        startUid = 165536;
      }
    ];
    subGidRanges = [
      {
        count = 100000;
        startGid = 165536;
      }
    ];
  };

  users.groups.homeassistant = { };
}
