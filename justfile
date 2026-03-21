hostname := shell('hostname')

# list recipes
default:
  just --list

# run just home-manager for, e.g. macOS without nix-darwin
home:
  home-manager switch --flake .#eve

# build the system configuration without switching
build:
  sudo nixos-rebuild build --flake .#{{hostname}} --print-build-logs

# build and switch to the new system configuration
switch:
  sudo nixos-rebuild switch --flake .#{{hostname}} --print-build-logs

# switch without printing build logs
switch_quiet:
  sudo nixos-rebuild switch --flake .#{{hostname}}

build_rescue:
  nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage

# test the configuration without applying it
dry_build:
  nixos-rebuild dry-activate --sudo --flake .#{{hostname}} #--upgrade

update_flake:
  nix flake update --flake .

# update NixOS channels https://nixos.wiki/wiki/Nix_channels
update_channels:
  sudo nix-channel --update

# invoke the garbage collector
# https://nixos.org/guides/nix-pills/11-garbage-collector.html
gc:
  nix-collect-garbage

# full system update
update_system: update_channels update_flake switch
