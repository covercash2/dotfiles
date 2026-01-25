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
    config = mkOption {
      type = types.either types.str types.attrs;
      description = ''
        configuration for the Apollo Router.
        can be provided as either a YAML string
        or as a Nix attribute set that will be converted to YAML.
        this configuration is written to `/mnt/space/apollo_router/router.yaml`
        and mounted into the container at `/dist/config/router.yaml`.

        see the Apollo Router documentation for available configuration options:
        https://www.apollographql.com/docs/graphos/routing/configuration/yaml
      '';
      example = {
        supergraph = {
          listen = "0.0.0.0:4000";
        };
        plugins = {
          "example.hello_world" = {
            name = "Bob";
          };
        };
      };
      default = {
        supergraph = {
          listen = "0.0.0.0:4000";
        };
      };
    };
  };

  config = lib.mkIf config.services.apollo_router.enable {
  config = mkIf config.services.apollo_router.enable {
    environment.etc."apollo_router/router.yaml".text =
      if builtins.isString config.services.apollo_router.config
      then config.services.apollo_router.config
      else lib.generators.toYAML {} config.services.apollo_router.config;

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

        # configure volumes to mount /mnt/space/apollo_router as /dis/config
        volumes = [
          "/etc/apollo_router/router.yaml:/dist/config/router.yaml"
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
>>>>>>> Conflict 1 of 1 ends
