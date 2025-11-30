{ ... }:

{
  # https://docs.frigate.video/frigate/installation#ports
  # TODO: fix this
  # services.frigate = {
  #   enable = true;
  #   hostname = "frigate.green";
  #   # video acceleration API
  #   vaapiDriver = "nvidia";
  #
  #   settings = {
  #     mqtt = {
  #       enabled = true;
  #       host = "localhost";
  #     };
  #
  #     cameras = {
  #       door = {
  #         ffmpeg.inputs = [
  #           {
  #             path = "rtsp://127.0.0.1:8554";
  #             roles = [
  #               "audio"
  #               "detect"
  #               "record"
  #             ];
  #           }
  #         ];
  #       };
  #     }; # cameras
  #
  #   }; # settings
  # }; # frigate

  virtualisation.oci-containers.containers = {
    # https://github.com/QuantumEntangledAndy/neolink/blob/master/README.md#docker
    # used to translate Reolink cameras' proprietary protocol to standard RTSP
    # neolink = {
    #   image = "docker.io/quantumentangledandy/neolink:v0.6.2";
    #   volumes = [
    #     "/mnt/space/neolink/config.toml:/etc/neolink.toml"
    #   ];
    #   environment = {
    #     NEO_LINK_PORT = "8554";
    #     NEO_LINK_MODE = "rtsp";
    #   };
    #   extraOptions = [
    #     "--network=host"
    #   ];
    # };
  };
}
