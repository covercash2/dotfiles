{
  config,
  lib,
  ...
}:

with lib;

# define options for the apollo_router module
{
  options.services.apollo_router = {
    enable = mkOption {
      type = types.bool;
      description = ''
        If enabled, deploys Apollo Router in an OCI container using the specified options.
      '';
      default = false;
    };

    port = mkOption {
      type = types.port;
      description = ''
        The port on which the Apollo Router will listen. Default is 4000.
      '';
      default = 4000;
    };
  };

  config = lib.mkIf config.services.apollo_router.enable {
    virtualisation.oci-containers.containers = {
      apollo_router = {
        image = "ghcr.io/apollographql/apollo-runtime:0.0.31-PR71";
        pull = "newer";
        autoStart = true;

        # configure the port mapping
        ports = [
          {
            containerPort = config.services.apollo_router.port;
            hostPort = config.services.apollo_router.port;
          }
        ];

        # additional options can be added here if needed in the future
        extraOptions = [];

        # configure volumes if needed
        volumes = [
          "/mnt/space/apollo_router/data:/var/lib/apollo_router_data"
        ];
      };
    };

    users.users.apollo_router = {
      isSystemUser = true;
      description = "Apollo Router user";
      group = "apollo_router";
      home = "/mnt/space/apollo_router";
      createHome = true;
      # subUidRanges and subGidRanges can be added here if user namespace remapping becomes necessary in the future.
    };

    users.groups.apollo_router = { };
  };
}
