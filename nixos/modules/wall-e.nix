# my ThinkPad config

{ config, lib, pkgs, ... }:

{
    networking.hostName = "wall-e";
    hardware.nvidia = {
        prime = {
            intelBusId = "PCI:1:0:0";
	    nvidiaBusId = "PCI:0:2:0";
	}
    }
}
