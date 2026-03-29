# secrets

Secrets are managed with [sops-nix] and encrypted with [rops] (a Rust implementation of sops)
using the host's SSH ed25519 key converted to an age key.

## how it works

- `secrets/green.yaml` is an age-encrypted YAML file committed to the repo.
- At NixOS activation, `sops-nix` reads `/etc/ssh/ssh_host_ed25519_key`, derives the age private
  key internally, and decrypts secrets declared under `sops.secrets.*` in `modules/sops.nix`.
- `sops.templates.*` can interpolate decrypted values into rendered files (e.g. an
  `EnvironmentFile` for a systemd service).

The age public key derived from the host SSH key is:

```
age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96
```

This is pinned in `.sops.yaml` under the `host_green` anchor.

> **Known issue:** `.sops.yaml` has `path_regex: nixos/secrets/.*\.yaml$` but the actual file
> lives at `secrets/green.yaml`. The creation rules therefore do **not** auto-apply. You must
> always pass `--age` explicitly when encrypting.

## current secrets (`modules/sops.nix`)

| key | owner | use |
|-----|-------|-----|
| `green_db_password` | green | interpolated into `green-env` template as `GREEN_DB_URL` |
| `mqtt_password` | green | interpolated into `green-env` template as `GREEN_MQTT_PASSWORD` |
| `pgadmin_password` | pgadmin | pgAdmin admin password |
| `miniflux_admin_password` | miniflux | rendered into `miniflux-credentials` template as `ADMIN_PASSWORD` |

## managing secrets with `nuenv/sops.nu`

`nuenv/sops.nu` provides nushell commands for common operations. Load it with:

```nu
overlay use nuenv/sops.nu
```

All commands derive the age private key from `/etc/ssh/ssh_host_ed25519_key` via `sudo ssh-to-age`
and pass it to `rops` via the `ROPS_AGE` environment variable.

```nu
secrets list                         # show all secret key names (requires sudo)
secrets add miniflux_admin_password  # prompt for value and save it (requires sudo)
secrets edit                         # open in $EDITOR interactively (requires TTY + sudo)
```

## raw `rops` commands

For cases where `sops.nu` is not available or you need more control.

**Decrypt (read):**
```nu
with-env {ROPS_AGE: (sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | str trim)} {
  rops decrypt secrets/green.yaml
}
```

**Add or update a key (decrypt → edit → re-encrypt):**
```nu
with-env {ROPS_AGE: (sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | str trim)} {
  rops decrypt secrets/green.yaml | save /tmp/s.yaml
}
# edit /tmp/s.yaml
rops encrypt --age age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96 -f yaml /tmp/s.yaml
| save --force secrets/green.yaml
rm /tmp/s.yaml
```

> **Note:** `rops` treats both stdin and a file path as "multiple inputs" — pipe the encrypted
> output to `save` rather than using `-i` / `--in-place` when the input is a file argument.

## declaring a new secret in NixOS

1. Add the key+value to `secrets/green.yaml` via `secrets add <key>` or the raw commands above.
2. Declare it in `modules/sops.nix`:
   ```nix
   sops.secrets.my_secret = {
     sopsFile = ../secrets/green.yaml;
     owner = "someuser";
     mode = "0400";
   };
   ```
3. Reference it via `config.sops.secrets.my_secret.path`, or use
   `config.sops.placeholder.my_secret` inside a `sops.templates` block.

## first-time setup for a new host

1. Derive the host's age public key:
   ```nu
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
2. Add the public key to `.sops.yaml` under a new anchor.
3. Re-encrypt the secrets file for the new key:
   ```nu
   rops keys update secrets/green.yaml
   ```
4. Add the host's SSH key path to `sops.age.sshKeyPaths` in its sops module:
   ```nix
   sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
   ```

## resetting the postgresql password

```nu
# 1. generate a new password
let pass = (openssl rand -base64 32 | str trim | str replace -a '=' '' | str replace -a '/' '' | str replace -a '+' '' | str substring 0..39)

# 2. set it in postgres (peer auth works without a password on the machine itself)
psql -U postgres -c $"ALTER USER green PASSWORD '($pass)';"

# 3. add it to the secrets file
overlay use nuenv/sops.nu
secrets add green_db_password  # paste $pass when prompted
```

[sops-nix]: https://github.com/Mic92/sops-nix
[rops]: https://github.com/getsops/rops
