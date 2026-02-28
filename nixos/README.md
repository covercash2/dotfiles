# NixOS configuration

an attempt to migrate my servers and my laptop to NixOS
for a few reasons

- declarative configuration
- code as documentation
- explicit package management
- easier recovery
- easy bringup of new machines
- unified configuration language (sort of sometimes)

seems alright.

# this repo

this configuration uses [Nix flakes]
to allow for git version control.

for now there are only a couple machines
that are managed this way,
and my understanding of Nix, NixOS, and flakes
is still growing.

different machine configurations are defined
in [`flake.nix`](./flake.nix).
in order to build the configuration
for the `green` machine,
navigate to this directory
(`cd <root>/nixos`)
and run:

```nu
sudo nixos-rebuild switch --flake .#green
```

common configuration--
users, packages, services, fonts, language configuration, etc--
are defined in `configuration.nix`.

generated hardware configurations are defined conventionally--
tbf my own convention--
by `<machine-name>-hardware-configuration.nix`.

machine specific configurations are defined conventionally--
again my own made up configuration--
in `modules/<machine-name>.nix`.

other configurations that are either
not specific to a certain machine
or too esoteric and may confuse machine configurations
(such as the Zigbee adapter configuration)
are stored under modules,
e.g. `openssh.nix` and `zigbee_receiver.nix`.

# rescue disk

a bootable ISO image for system recovery
is defined in [`rescue-disk.nix`](./rescue-disk.nix).
it includes essential tools like `fd`, `ripgrep`, `git`, and `nano`,
as well as an SSH service for remote rescue operations.
the default root password is `rescue` --
change it before using in any sensitive environment.

to build the rescue disk ISO,
navigate to the `nixos` directory
and run:

```nu
nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage
```

the resulting ISO will be available at `./result/iso/rescue-disk.iso`.

to write it to a USB drive, run:

```nu
sudo dd if=./result/iso/rescue-disk.iso of=/dev/sdX bs=4M status=progress
sync
```

replacing `/dev/sdX` with the target USB drive device.


[Nix flakes]: https://nixos.wiki/wiki/Flakes
