# dotfiles

Flake-based [NixOS] + [home-manager] configuration for multiple hosts.
System and user config are fully declarative — no separate dotfiles manager.

## hosts

| Host | Type | Notes |
|------|------|-------|
| green | NixOS | Main system — gaming, home automation, web services |
| wall-e | NixOS | ThinkPad laptop |
| hoss | NixOS | Embedded development |
| eve | macOS | Standalone home-manager (no nix-darwin) |

## structure

```
flake.nix                        # system + home-manager configs per host
configuration.nix                # shared NixOS base
home/                            # home-manager modules (packages, dotfiles, shell)
modules/                         # NixOS service modules
*-hardware-configuration.nix     # per-host hardware
secrets/                         # sops-nix encrypted secrets
```

## rebuilding

```bash
sudo nixos-rebuild switch --flake .#green   # NixOS hosts
home-manager switch --flake .#eve           # macOS standalone
```

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

Managed with [sops-nix] + [rops], encrypted to the host's SSH ed25519 key.

```bash
rops edit secrets/green.yaml     # decrypt, edit, re-encrypt
```

The age pubkey for `green` is `age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96`
(derived via `nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub`).

New secrets: add to `secrets/green.yaml`, declare in [`modules/sops.nix`](./modules/sops.nix).

Non-interactive decrypt (no TTY):
```bash
SOPS_AGE_KEY=<age-key> rops decrypt -f yaml secrets/green.yaml
```

Non-interactive encrypt (public key only):
```bash
printf 'key: value\n' | rops encrypt --age age1lvh945n... -f yaml > secrets/green.yaml
```

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
