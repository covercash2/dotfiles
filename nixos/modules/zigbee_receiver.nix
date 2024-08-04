# my zigbee receiver
# adds a udev rule to reassign the receiver to
# `/dev/ttyUSBSonoffZigbee`

# get device details with:
# ```nu
# udevadm info --attribute-walk $"--path=(udevadm info --query=path $"--name=($path_to_device)")"
# ```
# device details:
# ATTRS{idVendor}=="10c4"
# ATTRS{idProduct}=="ea60"
# SUBSYSTEM=="tty"
# SUBSYSTEMS=="usb"

{ config, lib, pkgs, ... }:

{
	services.udev.extraRules = ''
KERNEL=="ttyUSB[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="ttyUSBSonoffZigbee", GROUP="iot", MODE="0660"
		'';
}
