{
  description = "system config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ultron.url = "github:covercash2/ultron";
  };

  outputs = { self, nixpkgs, ultron, ... }@inputs: {
    nixosConfigurations.wall-e = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./wall-e-hardware-configuration.nix
        ./configuration.nix
        ./modules/wall-e.nix
      ];
    };
    nixosConfigurations.green = nixpkgs.lib.nixosSystem {

      system = "x86_64-linux";

      # Pass all inputs to modules in a way that avoids recursion
      specialArgs = {
        inherit ultron;
      };

      modules = [
        ./green-hardware-configuration.nix
        ./configuration.nix
        ./modules/green.nix
        ./modules/adguard.nix
        ./modules/openssh.nix
        ./modules/ultron.nix
        ./modules/zigbee_receiver.nix
				# ./modules/actualbudget.nix
      ];
    };
    nixosConfigurations.hoss = nixpkgs.lib.nixosSystem {
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
}
