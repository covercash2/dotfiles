{
  config,
  lib,
  pkgs,
  ...
}:

let
  apollo_router = pkgs.rustPlatform.buildRustPackage rec {
    pname = "router";
    version = "v2.11.0";

    src = pkgs.fetchFromGitHub {
      owner = "apollographql";
      repo = "router";
      rev = version;
      sha256 = "sha256-JuKsIGNz4AQC46D1zneio8mQ5Yik0jar0gDINrV0DXU=";
    };

    cargoHash = "sha256-NDDihTAoLbtfDdTyN6/8JpHwH/Mqetydc0L8Qj5axmk=";

    meta = with pkgs.lib; {
      description = ''
        Apollo Router is a high-performance, extensible GraphQL router built in Rust.
        https://github.com/apollographql/router/tree/v2.11.0?tab=readme-ov-file#usage
      '';
      homepage = "https://www.apollographql.com/docs/graphos/routing/self-hosted/containerization/docker-router-only";
      license = licenses.mit;
      maintainers = [ ];
    };
  };
in
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

    package = mkOption {
      type = types.package;
      description = ''
        The Nix package to use for Apollo Router. By default, it uses a custom package defined in this module.
        You can override this option to use a different version of Apollo Router or a custom build.
      '';
      default = apollo_router;
    };

    port = mkOption {
      type = types.port;
      description = ''
        The port on which the Apollo Router will listen. Default is 4000.
      '';
      default = 4000;
    };
    dataDir = mkOption {
      type = types.path;
      description = ''
        path to the directory where Apollo Router can store its data.
        this directory is mounted into the container at `/mnt/space/apollo_router`.

        make sure this directory exists and is writable by the `apollo_router` user.
      '';
      example = "/path/to/apollo_router_data";
      default = "/mnt/space/apollo_router";
    };
    schema = mkOption {
      type = types.path;
      description = ''
        path to the supergraph schema file.
        this file contains the GraphQL supergraph schema
        that Apollo Router uses to route requests.
        the file is mounted into the container at `/dist/schema/supergraph.graphql`.

        see the Apollo Router documentation for supergraph schema requirements:
        https://www.apollographql.com/docs/graphos/routing/self-hosted/containerization/docker-router-only
      '';
      example = "/path/to/supergraph.graphql";
      default = "${config.services.apollo_router.dataDir}/supergraph.graphql";
    };
    config = mkOption {
      type = types.either types.str types.attrs;
      description = ''
        configuration for the Apollo Router.
        can be provided as either a YAML string
        or as a Nix attribute set that will be converted to YAML.
        this configuration is written to `/etc/apollo_router/router.yaml`
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
        # sandbox = {
        #   enabled = true;
        # };
        supergraph = {
          introspection = true;
          listen = "0.0.0.0:4000";
        };
      };
    };
};

  config = mkIf config.services.apollo_router.enable {
    environment.etc."apollo_router/router.yaml".text =
      if builtins.isString config.services.apollo_router.config then
        config.services.apollo_router.config
      else
        lib.generators.toYAML { } config.services.apollo_router.config;

    systemd.services.apollo_router = {
      description = "Apollo Router service";
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "apollo_router";
        Group = "apollo_router";
        Restart = "always";
      };

      script = ''
        exec ${config.services.apollo_router.package}/bin/router \
          --config /etc/apollo_router/router.yaml \
          --supergraph ${config.services.apollo_router.schema}
      '';
    };

    users.users.apollo_router = {
      isSystemUser = true;
      description = "Apollo Router user";
      group = "apollo_router";
      home = config.services.apollo_router.dataDir;
      createHome = true;
      # subUidRanges and subGidRanges can be added here if user namespace remapping becomes necessary in the future.
      packages = [ apollo_router pkgs.protobuf_33 ];
    };

    users.groups.apollo_router = { };
  };
}
