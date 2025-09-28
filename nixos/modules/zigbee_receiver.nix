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

{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
    udev.extraRules = ''
            KERNEL=="ttyUSB[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="ttyUSBSonoffZigbee", GROUP="iot", MODE="0660"
      		'';

    mosquitto = {
      enable = true;

      persistence = true;
      dataDir = "/mnt/space/mosquitto/";

      logDest = [ "stdout" ];

      listeners = [
        {
          port = 1883;
          address = "0.0.0.0";

          users = {
            zigbee2mqtt = {
              acl = [
                "readwrite zigbee2mqtt/#"
                "readwrite homeassistant/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-zigbee2mqtt";
            };
            # zwavjs = {
            #   acl = [
            #     "readwrite zwavejs/#"
            #   ];
            #   hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-zwavejs";
            # };
            homeassistant = {
              acl = [
                "readwrite homeassistant/#"
                "readwrite zigbee2mqtt/#"
                "readwrite zwave/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-homeassistant";
            };
            chrash = {
              acl = [
                "readwrite #"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-chrash";
            };
          };
        }
      ];
    };

    zigbee2mqtt = {
      enable = true;

      dataDir = "/mnt/space/zigbee2mqtt/data";

      settings = {
        homeassistant = {
          enabled = true;
          discovery_topic = "homeassistant";
          status_topic = "homeassistant/status";
          experimental_event_entities = true;
          legacy_action_sensor = true;
        };
        permit_join = true;

        serial = {
          port = "/dev/ttyUSBSonoffZigbee";
          adapter = "zstack";
        };

        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://localhost:1883";
          user = "!secret.yaml user";
          password = "!secret.yaml password";
        };

        advanced = {
          log_output = [
            "console"
            "file"
          ];
        };

        availability = {
          enabled = true;
          active = {
            timeout = 1; # minutes
          };
          passive = {
            # TODO: increase this timeout
            timeout = 1; # minutes
          };
        };

        devices = {
          # prefix "0x00158d000af3" is Aqara sensors
          # the suffix for the friendly names corresponds to the sticker on the device
          "0x00158d000af394f6" = {
            friendly_name = "0x00158d000af394f6";
            availability = true;
          };
          "0x00158d000af394f8" = {
            friendly_name = "bedroom temp (0)";
          };
          "0x00158d008b04a887" = {
            friendly_name = "office temp (2)";
          };
          "0x282c02bfffea5495" = {
            friendly_name = "0x282c02bfffea5495";
          };
          "0x282c02bfffec2f84" = {
            friendly_name = "0x282c02bfffec2f84";
          };
          "0x282c02bfffec78bf" = {
            friendly_name = "0x282c02bfffec78bf";
          };
          "0x282c02bfffec84f8" = {
            friendly_name = "0x282c02bfffec84f8";
          };
          "0xa4c13812d9bd371a" = {
            friendly_name = "0xa4c13812d9bd371a";
          };
          "0xa4c1385989d0c74d" = {
            friendly_name = "living room presence sensor";
          };
          # "0xb0ce1814000" is a prefix for Sengled light bulbs?
          "0xb0ce18140003dc0e" = {
            friendly_name = "tree light left";
            availability = true;
          };
          "0xb0ce181400052ad2" = {
            friendly_name = "kitchen light";
          };
          "0xb0ce181400067f53" = {
            friendly_name = "tree light center";
          };
          "0xb0ce18140008a960" = {
            friendly_name = "tree light right";
          };
          "0xb0ce181400184485" = {
            friendly_name = "0xb0ce181400184485";
          };
          "0xb0ce18140018463f" = {
            friendly_name = "office shelf lamp";
          };
          "0xb0ce181400184699" = {
            friendly_name = "couch lamp";
          };
          "0xb0ce18140018633a" = {
            friendly_name = "0xb0ce18140018633a";
          };
          "0xb0ce18140363e41f" = {
            friendly_name = "0xb0ce18140363e41f";
          };
          "0xf4b3b1fffee7b489" = {
            friendly_name = "0xf4b3b1fffee7b489";
          };
        };
      };
    };
  };

  users.users = {
    zigbee2mqtt = {
      isSystemUser = true;
      description = "Zigbee2MQTT user";
      extraGroups = [ "iot" ];
    };
    chrash = {
      packages = [ pkgs.mosquitto ];
    };
  };
}
