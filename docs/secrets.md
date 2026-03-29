# secrets

secrets are managed with [sops-nix] and ecrypted with [rops] using the host's SSH ed25519 key.

## how it works

- at activation, `[sops-nix]` reads `/etc/ssh/ssh_host_ed25519_key`
and uses it to decrypt files listed under `sops.secret.*`.
- `sops.templates.*` can interpolate decrypted values into rendered files
    (e.g. an `EnvironmentFile` for a systemd service).
- the age public key derived from the SSH host key is pinned in [.sops.yaml]
    so that `[rops]` knows which key to encrypt to when creating or editing secrets.

## editing secrets

```nu
rops edit secrets/green.yaml
```

#### non-interactive environments (e.g. Claude Code)

`rops edit` requires a TTY.
`rops decrypt` requires the SSH host private key (root-only).
in a non-interactive shell, use these workarounds:

##### decrypt (--requires sudo)

```nu
sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key
# pipe the resulting age private key into SOPS_AGE_KEY env var, then:
SOPS_AGE_KEY=<age-private-key> rops decrypt -f yaml secrets/green.yaml
```

##### encrypt/overwrite (no sudo):

```nu
('key: value\n'
| rops encrypt --age age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96 -f yaml
| save --force secrets/green.yaml)
```

> note: rops sees stdin AND a file path as "multiple inputs" — always use > file redirection rather than the -i / --in-place flag when piping.

## adding a new secret

1. add the key to `secrets/green.yaml` via `rops edit`
2. declare `sops.secrets.<name>` in `modules/sops.nix`
3. reference `config.sops.secrets.<name>.path` (or use a template) where the secret is needed

### resetting the postgresql password

```nu
# 1. generate a new password
let pass = (openssl rand -base64 32 | tr -d '=/+' | head -c 40)

# 2. set it in postgres (peer auth works without a password from the machine itself)
psql -U postgres -c $"ALTER USER green PASSWORD '($pass)';"

# 3. re-encrypt the secrets file
($"green_db_password: ($pass)\n"
| rops encrypt --age age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96 -f yaml
| save --force secrets/green.yaml
)
```

## first time setup

1. derive host's age public key
2. add it to `.sops.yaml` under a new anchor
3. re-encrypt existing secrets files for the new key:
```nu
rops keys update --age <new-age-pubkey> secrets/green.yaml
```
4. add the host's SSH key path to `sops.age.sshKeyPaths` in its [sops] module

[sops-nix]: https://github.com/Mic92/sops-nix
[rops]: https://github.com/getsops/rops
