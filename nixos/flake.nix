{
  description = "system config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ultron = {
      url = "github:covercash2/ultron";
      # Make ultron use the same nixpkgs to avoid conflicts
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ultron, ... }@inputs:
  let
    # Helper function to create a system configuration for any architecture
    mkSystem = system: hostName: modules:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = modules ++ [
          # Import the system-specific Ultron module
          ultron.nixosModules.default
          # add other custom modules here

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
