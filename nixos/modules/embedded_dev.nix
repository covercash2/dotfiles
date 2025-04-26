{ config, lib, pkgs, ... }:

{
  users = {
    groups.dialout = {};
    users.chrash.extraGroups = [ "dialout" ];
  };

  services.udev.extraRules = ''
    # ESP32 serial port rules
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", GROUP="dialout", MODE="0660"
  '';
}
