{
	description = "system config flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }@inputs: {
		nixosConfigurations.wall-e = nixpkgs.lib.nixosSystem {

			system = "x86_64-linux";

			modules = [
				./configuration.nix
			];
		};
	};
}
