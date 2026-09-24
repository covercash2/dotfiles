# secrets

secrets are managed with [sops-nix] and encrypted with [rops] (a Rust implementation of sops),
one file per host (`secrets/<host>.yaml`), each encrypted to that host's own age key (its SSH
ed25519 key, converted via `ssh-to-age`) — see the one-file-per-host/single-recipient model in
`nuenv/sops.nu`.

## how it works

- `secrets/<host>.yaml` is age-encrypted and committed to the repo.
- at NixOS activation, `sops-nix` reads `/etc/ssh/ssh_host_ed25519_key`, derives the age private
  key internally, and decrypts secrets declared under `sops.secrets.*` in that host's sops module.
- `sops.templates.*` can interpolate decrypted values into rendered files (e.g. an
  `EnvironmentFile` for a systemd service).

host age public keys are pinned in `.sops.yaml` and mirrored in `HOST_PUBKEYS` in
`nuenv/sops.nu` — run `secrets` (no args) to list known hosts.

## current secrets

declared in each host's sops module (`modules/sops.nix` for green,
[`modules/hoss-sops.nix`](../modules/hoss-sops.nix) for hoss) — `sops.secrets.*` and
`sops.templates.*` there are the source of truth for what exists, who owns
it, and what it's used for.

## managing secrets with `nuenv/sops.nu`

`nuenv/sops.nu` provides nushell commands for common operations. load it with:

```nu
overlay use nuenv/sops.nu
```

commands take `--host` (default `green`) and derive the age private key from
`/etc/ssh/ssh_host_ed25519_key` via `sudo ssh-to-age`.

```nu
secrets list --host hoss              # show a host's secret key names (requires sudo)
secrets add miniflux_admin_password   # prompt for value and save to green's file (requires sudo)
secrets edit                          # open green's file in $EDITOR (requires TTY + sudo)
secrets init --host hoss my_key       # bootstrap a new host's secrets file (no sudo needed)
```

## raw `rops` commands

for cases where `sops.nu` is not available or you need more control.

**decrypt (read):**
```nu
with-env {ROPS_AGE: (sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | str trim)} {
  rops decrypt secrets/<host>.yaml
}
```

**add or update a key (decrypt → edit → re-encrypt):**
```nu
with-env {ROPS_AGE: (sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | str trim)} {
  rops decrypt secrets/<host>.yaml | save /tmp/s.yaml
}
# edit /tmp/s.yaml
rops encrypt --age <host's pubkey — see HOST_PUBKEYS in nuenv/sops.nu> -f yaml /tmp/s.yaml
| save --force secrets/<host>.yaml
rm /tmp/s.yaml
```

> **note:** `rops` treats both stdin and a file path as "multiple inputs" — pipe the encrypted
> output to `save` rather than using `-i` / `--in-place` when the input is a file argument.

## declaring a new secret in NixOS

1. add the key+value via `secrets add <key> [--host <h>]` or the raw commands above.
2. declare it in that host's sops module:
   ```nix
   sops.secrets.my_secret = {
     sopsFile = ../secrets/<host>.yaml;
     owner = "someuser";
     mode = "0400";
   };
   ```
3. reference it via `config.sops.secrets.my_secret.path`, or use
   `config.sops.placeholder.my_secret` inside a `sops.templates` block.

## first-time setup for a new host

1. derive the host's age public key:
   ```nu
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
2. add it to `HOST_PUBKEYS` in `nuenv/sops.nu`, and as a new anchor +
   `creation_rules` entry in `.sops.yaml`.
3. create the host's secrets file:
   ```nu
   secrets init --host <host> <first_key>
   ```
4. add the host's SSH key path to `sops.age.sshKeyPaths` in its sops module:
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
