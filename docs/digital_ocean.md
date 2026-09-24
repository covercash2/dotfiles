# foundry (Digital Ocean VPS)

public ingress + DNS replica. see [topology.md](./topology.md) for its role
and [`modules/foundry.nix`](../modules/foundry.nix) for the config.

## deploying

```bash
just switch-foundry
```

see the `switch-foundry` recipe in [`justfile`](../justfile) — builds on
`hoss` (which [`modules/hoss-builder.nix`](../modules/hoss-builder.nix)
signs for), deploys to `foundry` over Tailscale.

works from any machine on the tailnet, not just from `hoss` —
`--build-host` pins the build step to `hoss` regardless of where the command
runs.

## first-time `ssh` trust

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
