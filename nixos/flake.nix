{
	description = "system config flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }@inputs: {
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

			modules = [
				./green-hardware-configuration.nix
				./configuration.nix
				./modules/green.nix
				./modules/openssh.nix
				./modules/zigbee_receiver.nix
			];
		};
	};
}
