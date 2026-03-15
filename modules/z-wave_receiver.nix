{ ... }:

{

  services = {
    # zwave-js-ui bundles zwave-js
    # this is a wrapper around `zwave-js-server`
    zwave-js-ui = {
      enable = true;
      serialPort = "/dev/ttyUSBHomeSeerZWave";
      settings = {
        PORT = "8091";
      };
    };
    # find idVendor and idProduct with `cyme`
    udev.extraRules = ''
      KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="ttyUSBHomeSeerZWave", GROUP="iot", MODE="0660"
    '';
  };

  users.users = {
    zwave-js-ui = {
      isSystemUser = true;
      description = "Z-Wave JS UI user";
      group = "iot";
      createHome = false;
    };
    # zwave-js = {
    #   isSystemUser = true;
    #   description = "Z-Wave JS user";
    #   group = "iot";
    #   createHome = false;
    # };
  };
}
