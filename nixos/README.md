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


# secrets

Secrets (database passwords, API keys, etc.) are managed with
[sops-nix] and encrypted with [rops] using the host's SSH ed25519 key.
The plaintext never appears in the Nix store.

## how it works

- At NixOS activation, sops-nix reads `/etc/ssh/ssh_host_ed25519_key`
  and uses it to decrypt files listed under `sops.secrets.*`.
- `sops.templates.*` can interpolate decrypted values into rendered
  files (e.g. an `EnvironmentFile` for a systemd service).
- The age public key derived from the SSH host key is pinned in
  [`.sops.yaml`](./.sops.yaml) so that `rops` knows which key to
  encrypt to when creating or editing secrets.

## key management

The age public key for the `green` host is:

```
age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96
```

Derived from the SSH host key via:

```nu
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

## editing secrets

```nu
rops edit nixos/secrets/green.yaml
```

`rops` will decrypt, open `$EDITOR`, then re-encrypt on save.

### non-interactive environments (e.g. Claude Code)

`rops edit` requires a TTY. `rops decrypt` requires the SSH host private
key (root-only). In a non-interactive shell, use these workarounds:

**decrypt** — requires sudo to read the private key:

```nu
sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key
# pipe the resulting age private key into SOPS_AGE_KEY env var, then:
SOPS_AGE_KEY=<age-private-key> rops decrypt -f yaml nixos/secrets/green.yaml
```

**encrypt / overwrite** — only needs the public key (no sudo):

```nu
printf 'key: value\n' | rops encrypt --age age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96 -f yaml > nixos/secrets/green.yaml
```

Note: `rops` sees stdin AND a file path as "multiple inputs" — always use
`> file` redirection rather than the `-i` / `--in-place` flag when piping.

## adding a new secret

1. Add the key to `nixos/secrets/green.yaml` via `rops edit`
2. Declare `sops.secrets.<name>` in `modules/sops.nix`
3. Reference `config.sops.secrets.<name>.path` (or use a template)
   wherever the secret is needed

## current secrets (`nixos/secrets/green.yaml`)

| Key | Used by |
|-----|---------|
| `green_db_password` | Rendered into `sops.templates."green-env"` as `GREEN_DB_URL=…`, loaded by the green systemd service via `EnvironmentFile` |

### resetting the postgresql password

The `green` PostgreSQL user password must match the value in `nixos/secrets/green.yaml`.
To reset both together:

```nu
# 1. generate a new password
let pass = (openssl rand -base64 32 | tr -d '=/+' | head -c 40)

# 2. set it in postgres (peer auth works without a password from the machine itself)
psql -U postgres -c $"ALTER USER green PASSWORD '($pass)';"

# 3. re-encrypt the secrets file
printf $"green_db_password: ($pass)\n" | rops encrypt --age age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96 -f yaml > nixos/secrets/green.yaml
```

## first-time setup on a new host

1. Derive the host's age public key (command above)
2. Add it to `.sops.yaml` under a new anchor
3. Re-encrypt existing secrets files for the new key:
   ```nu
   rops keys update --age <new-age-pubkey> nixos/secrets/green.yaml
   ```
4. Add the host's SSH key path to `sops.age.sshKeyPaths` in its
   sops module

[sops-nix]: https://github.com/Mic92/sops-nix
[rops]: https://github.com/getsops/rops
[Nix flakes]: https://nixos.wiki/wiki/Flakes
