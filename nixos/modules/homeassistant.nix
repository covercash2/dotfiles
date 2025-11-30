{
  ...
}:

{
  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      pull = "newer";

      autoStart = true;

      podman.user = "homeassistant";

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
