{
  description = "system config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ultron = {
      type = "github";
      owner = "covercash2";
      repo = "ultron";
      rev = "05be4f8b3df65e0494229c03b8268a092736c39a";
      # Make ultron use the same nixpkgs to avoid conflicts
      inputs.nixpkgs.follows = "nixpkgs";
    };
    green = {
      type = "github";
      owner = "covercash2";
      repo = "green";
      rev = "267d3be4899840ac0d79cedb0a6386438ad35d0b";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cli.url = "github:nix-community/nixos-cli";
    sops-nix.url = "github:Mic92/sops-nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,

      green,
      ultron,
      nixos-cli,
      sops-nix,
      disko,
      ...
    }:
    let
      # Helper function to create a system configuration for any architecture
      mkSystem =
        system: hostName: username: modules:
        nixpkgs.lib.nixosSystem {
          modules = modules ++ [
            # Import the system-specific Ultron module
            ultron.nixosModules.default
            green.nixosModules.default
            nixos-cli.nixosModules.nixos-cli
            sops-nix.nixosModules.sops

            # Share the hostname
            { networking.hostName = hostName; }

            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = hostName; inherit username; withDesktop = true; };
              home-manager.users.${username} = import ./home;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };

    in
    {
      nixosConfigurations = {

        wall-e = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./wall-e-hardware-configuration.nix
            ./configuration.nix
            ./modules/nvidia.nix
            ./modules/desktop.nix
            ./modules/wall-e.nix
            ./modules/ds4.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "wall-e"; username = "chrash"; withDesktop = true; };
              home-manager.users.chrash = import ./home;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };

        green = mkSystem "x86_64-linux" "green" "chrash" ([
          ./green-hardware-configuration.nix
          ./configuration.nix
          ./modules/nvidia.nix
          ./modules/desktop.nix
          # ./modules/apollo_router.nix
          ./modules/green.nix

          ./modules/adguard.nix
          ./modules/adguardhome-sync.nix
          ./modules/dnsmasq.nix
          ./modules/shared-ca.nix
          ./modules/foundryvtt.nix
          ./modules/homeassistant.nix
          ./modules/openssh.nix
          ./modules/postgres.nix
          ./modules/steam_server.nix
          ./modules/sunshine.nix
          ./modules/ultron.nix
          ./modules/video_surveillance.nix
          ./modules/z-wave_receiver.nix
          ./modules/zigbee_receiver.nix
          ./modules/ntfy.nix
          ./modules/sops.nix
          ./modules/alerting.nix

          # ./modules/actualbudget.nix
          # ./modules/immich.nix
        ]);

        hoss = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hoss-hardware-configuration.nix
            ./configuration.nix
            ./modules/nvidia.nix
            ./modules/desktop.nix
            ./modules/hoss.nix
            ./modules/hoss-sops.nix
            ./modules/openssh.nix
            ./modules/embedded_dev.nix
            ./modules/steam_server.nix
            ./modules/hoss-builder.nix
            ./modules/shared-ca.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "hoss"; username = "chrash"; withDesktop = true; };
              home-manager.users.chrash = import ./home;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };

        # Digital Ocean VPS — ingress and high availability
        foundry = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./foundry-hardware-configuration.nix
            ./configuration.nix
            ./modules/foundry-disk.nix
            ./modules/foundry.nix
            ./modules/adguard-replica.nix
            ./modules/openssh.nix
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "foundry"; username = "chrash"; withDesktop = false; };
              home-manager.users.chrash = import ./home;
              home-manager.backupFileExtension = "hm-backup";
            }
          ];
        };

        # bootable rescue disk ISO for system recovery
        rescue-disk = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./rescue-disk.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "rescue-disk"; username = "chrash"; withDesktop = false; };
              home-manager.users.chrash = import ./home;
            }
          ];
        };
      };

      # Standalone home-manager for macOS (eve and boxer)
      homeConfigurations = {
        eve = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
            overlays = [
              # nushell 0.112.1 has SHLVL tests that fail in the Nix sandbox
              (final: prev: {
                nushell = prev.nushell.overrideAttrs (_: { doCheck = false; });
              })
            ];
          };
          extraSpecialArgs = { hostname = "eve"; username = "chrash"; };
          modules = [ ./home ];
        };

        boxer = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            hostname = "m-ry6wtc3pxk";
            username = "c0o02bc";
            # Add work-specific nushell script directories here
            extraNuLibDirs = [
              "/Users/c0o02bc/wmgithub/c0o02bc/nuenv/"
            ];
          };
          modules = [ ./home ];
        };
      };
    };
}
