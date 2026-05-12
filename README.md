# dotfiles

Flake-based [NixOS] + [home-manager] configuration for multiple hosts.
System and user config are fully declarative — no separate dotfiles manager.

## hosts

Hosts and their module composition are defined in [`flake.nix`](./flake.nix).

## structure

```
flake.nix                        # entry point — all host definitions
configuration.nix                # shared NixOS base
modules/                         # NixOS service and hardware modules
home/                            # home-manager config
*-hardware-configuration.nix     # per-host hardware
secrets/                         # sops-nix encrypted secrets (see docs/secrets.md)
nuenv/                           # nushell utility scripts
```

## rebuilding

```bash
just switch     # NixOS (autodetects hostname)
just home       # macOS standalone home-manager
just --list     # all available recipes
```

Hosts without a local repo copy (e.g. VPS) pull directly from GitHub:

```bash
sudo nixos-rebuild switch --flake github:covercash2/dotfiles#<host>
```

## Network topology

See [docs/topology.md](./docs/topology.md) for machine inventory, services, IPs, and infrastructure overview.

## Digital Ocean VPS

See [docs/digital_ocean.md](./docs/digital_ocean.md).

## home-manager

User config lives in [`home/`](./home/). Host-specific values (e.g. git email)
are passed via `specialArgs.hostname` — see [`flake.nix`](./flake.nix).

## services (green)

HTTP services follow the pattern in [`modules/sunshine.nix`](./modules/sunshine.nix):
enable the service, register a route in `services.green.routes`, configure a
[Caddy] virtual host using mkcert certs (`config.services.mkcert.certPath/keyPath`).

For HTTPS backends, Caddy needs `transport http { tls_insecure_skip_verify }`.

Some services run as user units — check with `systemctl --user status <service>`.

## secrets

Managed with [sops-nix] + [rops], see [docs/secrets.md](./docs/secrets.md).


## rescue disk

```bash
nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage
sudo dd if=./result/iso/rescue-disk.iso of=/dev/sdX bs=4M status=progress
```

Default root password is `rescue`. See [`rescue-disk.nix`](./rescue-disk.nix).

[NixOS]: https://nixos.org
[home-manager]: https://github.com/nix-community/home-manager
[Caddy]: https://caddyserver.com
[sops-nix]: https://github.com/Mic92/sops-nix
[rops]: https://github.com/getsops/rops
