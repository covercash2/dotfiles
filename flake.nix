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
      rev = "cea15b98a065774506047dd3ad70d8db0716591e";

      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cli.url = "github:nix-community/nixos-cli";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,

      green,
      ultron,
      nixos-cli,
      sops-nix,
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
              # Back up any files chezmoi already placed before home-manager takes over
              home-manager.backupFileExtension = "chezmoi-backup";
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
            ./modules/wall-e.nix
            ./modules/ds4.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "wall-e"; username = "chrash"; withDesktop = true; };
              home-manager.users.chrash = import ./home;
              home-manager.backupFileExtension = "chezmoi-backup";
            }
          ];
        };

        green = mkSystem "x86_64-linux" "green" "chrash" ([
          ./green-hardware-configuration.nix
          ./configuration.nix
          # ./modules/apollo_router.nix
          ./modules/green.nix

          ./modules/adguard.nix
          ./modules/certificates.nix
          ./modules/foundry.nix
          ./modules/homeassistant.nix
          # ./modules/immich.nix
          ./modules/starship-jj.nix
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

          # ./modules/actualbudget.nix
          # ./modules/immich.nix
        ]);

        hoss = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hoss-hardware-configuration.nix
            ./configuration.nix
            ./modules/hoss.nix
            ./modules/openssh.nix
            ./modules/embedded_dev.nix
            ./modules/steam_server.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { hostname = "hoss"; username = "chrash"; withDesktop = true; };
              home-manager.users.chrash = import ./home;
              home-manager.backupFileExtension = "chezmoi-backup";
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
          };
          extraSpecialArgs = { hostname = "eve"; username = "chrash"; };
          modules = [ ./home ];
        };
        boxer = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { hostname = "m-ry6wtc3pxk"; username = "c0o02bc"; };
          modules = [ ./home ];
        };
      };
    };
}
