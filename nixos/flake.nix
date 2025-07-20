{
  description = "system config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ultron = {
      type = "github";
      owner = "covercash2";
      repo = "ultron";
      rev = "0875adf8d630246ac3d0c338157a5b89fa0c57a8";
      # Make ultron use the same nixpkgs to avoid conflicts
      inputs.nixpkgs.follows = "nixpkgs";
    };
    green = {
      type = "github";
      owner = "covercash2";
      repo = "green";
      rev = "7193b35d268737c606f87b525ddd3596b2738476";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ultron, green, ... }@inputs:
  let
    # Helper function to create a system configuration for any architecture
    mkSystem = system: hostName: modules:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = modules ++ [
          # Import the system-specific Ultron module
          ultron.nixosModules.default
          green.nixosModules.default

          # Share the hostname
          { networking.hostName = hostName; }
        ];
      };
  in {
    nixosConfigurations = {
      wall-e = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./wall-e-hardware-configuration.nix
          ./configuration.nix
          ./modules/wall-e.nix
        ];
      };
      green = mkSystem "x86_64-linux" "green" (
        [
          ./green-hardware-configuration.nix
          ./configuration.nix
          ./modules/green.nix
          ./modules/adguard.nix
          ./modules/openssh.nix
          ./modules/zigbee_receiver.nix
          # ./modules/actualbudget.nix
          ./modules/ultron.nix
          ./modules/certificates.nix
        ]
      );

      hoss = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hoss-hardware-configuration.nix
          ./configuration.nix
          ./modules/hoss.nix
          ./modules/openssh.nix
          ./modules/embedded_dev.nix
        ];
      };
    };
  };
}
