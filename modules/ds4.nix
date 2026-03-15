# PS4 (DS4) controller udev rules.
# Was missing from NixOS config — migrated from:
#   udev/51-disable-DS3-DS4-motion-controls.rules
#   root_etc/udev/rules.d (uinput rule)
# Import this module on hosts where a DS4 controller is used.
{ ... }:

{
  services.udev.extraRules = ''
    # Disable DS3/DS4 motion sensors and touchpad as joystick inputs
    # (prevents double-input issues in games)
    SUBSYSTEM=="input", ATTRS{name}=="*Controller Motion Sensors", RUN+="/bin/rm %E{DEVNAME}", ENV{ID_INPUT_JOYSTICK}=""
    SUBSYSTEM=="input", ATTRS{name}=="*Controller Touchpad", RUN+="/bin/rm %E{DEVNAME}", ENV{ID_INPUT_JOYSTICK}=""

    # uinput access for input remapping tools (xremap, etc.)
    KERNEL=="uinput", GROUP="input", TAG+="uaccess"
  '';
}
