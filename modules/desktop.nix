# Desktop environment configuration shared by wall-e, green, and hoss.
# Not imported by headless hosts (foundry).
{ pkgs, ... }:

{
  networking.networkmanager.enable = true;

  security.rtkit.enable = true; # required for PipeWire

  services = {
    displayManager.enable = false;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    gvfs.enable = true;   # mount, trash, and other file manager functionalities
    tumbler.enable = true; # thumbnail support for images
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    fira-code-symbols
  ];

  programs = {
    thunar.enable = true;
    hyprland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg = {
    portal.enable = true;
    mime = {
      defaultApplications = {
        "inode/directory" = "thunar.desktop";

        "default-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      };
    };
    terminal-exec.enable = true;
  };
}
