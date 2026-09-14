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
            # https://mosquitto.org/documentation/authentication-methods/
            zigbee2mqtt = {
              acl = [
                "readwrite zigbee2mqtt/#"
                "readwrite homeassistant/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-zigbee2mqtt";
            };
            zwavejs = {
              acl = [
                "readwrite zwavejs/#"
                "readwrite homeassistant/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-zwavejs";
            };
            homeassistant = {
              acl = [
                "readwrite homeassistant/#"
                "readwrite zigbee2mqtt/#"
                "readwrite zwave/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-homeassistant";
            };
            frigate = {
              acl = [
                "readwrite frigate/#"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-frigate";
            };
            chrash = {
              acl = [
                "readwrite #"
              ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-chrash";
            };
            green = {
              acl = [ "readwrite #" ];
              hashedPasswordFile = "${config.services.mosquitto.dataDir}passwd-green";
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

        # Web UI + network map, for debugging device availability/routing.
        # Bound to green's LAN address only — not reachable from the WAN.
        frontend = {
          enabled = true;
          port = 8877;
          host = "192.168.2.216";
        };

        # TODO: DELETE once the SLZB-MR1U migration is confirmed stable.
        # Previous coordinator: Sonoff Zigbee 3.0 USB Dongle Plus (CC2652P),
        # attached to green over USB via the ttyUSBSonoffZigbee udev symlink.
        # serial = {
        #   port = "/dev/ttyUSBSonoffZigbee";
        #   adapter = "zstack";
        # };

        # SLZB-MR1U over the network. Port 7638 = CC2652P7 radio (Z-Stack,
        # same stack as the old Sonoff so the coordinator backup restores);
        # port 6638 = the EFR32MG21 radio (ember). Static IP set on the device.
        serial = {
          port = "tcp://192.168.2.165:7638";
          adapter = "zstack";
          baudrate = 115200; # ignored over TCP; kept to match SLZB's generated config
          disable_led = false;
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
          transmit_power = 20; # SLZB-MR1U max
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
            friendly_name = "server room (1)";
            availability = true;
          };
          "0x00158d000af394f8" = {
            friendly_name = "bedroom temp (0)";
          };
          "0x00158d008b04a887" = {
            friendly_name = "office temp (2)";
          };
          # prefix "0x282c02bfff" is
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
          # "0xb0ce1814000" is a prefix for Sengled light bulbs
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
            friendly_name = "office table lamp";
          };
          "0xb0ce18140018463f" = {
            friendly_name = "office shelf lamp";
          };
          "0xb0ce181400184699" = {
            friendly_name = "couch lamp";
          };
          "0xb0ce18140018633a" = {
            friendly_name = "bedroom lamp";
          };
          "0x841826000003959d" = {
            friendly_name = "laundry light";
          };
          "0xb0ce18140363e41f" = {
            friendly_name = "kitchen cabinet lights";
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

  # zigbee2mqtt frontend (bound to the LAN address above, so this only opens
  # it up on the LAN, not the WAN).
  networking.firewall.allowedTCPPorts = [ 8877 ];

  # zigbee2mqtt's onboarding/recovery server (only started when the config
  # fails validation) is hardcoded to 0.0.0.0:8080 unless overridden here;
  # moved off 8080 so it can't collide with other services.
  systemd.services.zigbee2mqtt.environment.Z2M_ONBOARD_URL = "http://0.0.0.0:8081";
}
