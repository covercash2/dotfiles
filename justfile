hostname := shell('hostname')

# list recipes
default:
  just --list

# run just home-manager for, e.g. macOS without nix-darwin
home:
  home-manager switch --flake .#eve

# rebuild the system to, e.g., install packages or change configuration
build_quiet:
  sudo nixos-rebuild switch --flake .#{{hostname}} --upgrade

build:
  sudo nixos-rebuild switch --flake .#{{hostname}} --upgrade --print-build-logs

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
update_system: update_channels update_flake build
