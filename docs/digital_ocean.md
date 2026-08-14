# foundry (Digital Ocean VPS)

public ingress + DNS replica. see [topology.md](./topology.md) for its role
and [`modules/foundry.nix`](../modules/foundry.nix) for the config.

## deploying

```bash
just switch-foundry
```

builds the `foundry` config on `hoss`, copies the closure to `foundry`, and
activates it there:

```just
switch-foundry:
  nixos-rebuild switch --flake .#foundry --build-host chrash@hoss --target-host chrash@foundry --use-remote-sudo --print-build-logs
```

- `--build-host chrash@hoss` — build on `hoss`, not the droplet.
  [`modules/hoss-builder.nix`](../modules/hoss-builder.nix) signs `hoss`'s
  store paths so `foundry` trusts them without `--no-check-sigs`.
- `--target-host chrash@foundry` — copy the closure to `foundry` and
  activate.
- `--use-remote-sudo` — activation runs as `chrash` via `sudo`, not root.

`hoss` and `foundry` both resolve via Tailscale MagicDNS (`faun-truck`
tailnet). works from any machine on the tailnet, not just from `hoss` —
`--build-host` pins the build step to `hoss` regardless of where the command
runs.

## first-time ssh trust

```bash
ssh-keyscan foundry >> ~/.ssh/known_hosts
```

verify the fingerprint against the droplet console before trusting it.

## initial install

`foundry` was provisioned with `nixos-anywhere` — disko-based, **destructive**
(wipes the disk):

```bash
just deploy-foundry
```

reinstall only. not for routine updates.

## home-manager only

for home-manager-only changes, run directly on `foundry` instead:

```bash
just home-foundry
```
