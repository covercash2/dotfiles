{ ... }:

{
	services.udev.extraRules = ''
KERNEL=="ttyUSB[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="ttyUSBHomeSeerZWave", GROUP="iot", MODE="0660"
		'';
}
