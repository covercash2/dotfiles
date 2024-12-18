# Actual Budget open source budgeting softward
# https://actualbudget.org/docs/install/docker
# https://nixos.wiki/wiki/NixOS_Containers

{ config, pkgs, ... }:
{
	config.virtualisation.oci-containers.containers = {
		actualserver = {
			image = "actualbudget/actual-server:latest";
      ports = ["127.0.0.1:5006:5006"];
			# pull = "always";
      volumes = [
        "/mnt/media/actual_budget/:/data"
      ];
		};
	};
}
