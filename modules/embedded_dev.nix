{ config, lib, pkgs, ... }:

{
  users = {
    groups.dialout = {};
    users.chrash.extraGroups = [ "dialout" ];
  };

  # openocd and platformio bundle their own udev rules in nixpkgs
  # uncomment to enable:
  # services.udev.packages = with pkgs; [ openocd platformio-core ];

  services.udev.extraRules = ''
    # ESP32 serial port rules
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", GROUP="dialout", MODE="0660"

    # FT232 USB <-> serial converter (was missing from NixOS config, migrated from udev/99-ftdi.rules)
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE:="0666"

    # Android ADB (was missing from NixOS config, migrated from udev/android.rules)
    SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", ATTR{idProduct}=="4ee7", MODE="0660", GROUP="dialout", SYMLINK+="android%n"

    # STM32F3DISCOVERY rev C+ - ST-LINK/V2-1 (was missing from NixOS config, migrated from udev/99-openocd.rules)
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
  '';
}
