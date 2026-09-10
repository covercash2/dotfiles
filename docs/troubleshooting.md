# troubleshooting

## nvidia driver/library version mismatch after rebuild

**`nvidia-container-toolkit-cdi-generator.service` fails, `switch-to-configuration` exits 4**

```
Could not determine driver version: libnvsandboxutils is not available
failed to initialize nvml: Driver/library version mismatch
```

`modules/nvidia.nix` tracks `config.boot.kernelPackages.nvidiaPackages.stable`,
so a rebuild can pull in a newer driver than the kernel module currently
loaded in memory. `nixos-rebuild switch` updates the userspace libraries on
disk immediately, but the kernel module isn't reloaded until something
unloads it (or the host reboots) — so NVML calls against the new userspace
libs fail against the old module.

the rebuild itself succeeds; only the CDI generator (and anything depending
on GPU passthrough to containers) is affected until the module reloads.

**fix:** reboot the host. this is the standard remedy — it loads the kernel
module fresh against the new driver version. unloading/reloading the nvidia
modules manually is possible but fragile on a host with active GPU users
(X, containers, etc.), so a reboot is the reliable option.

## a service fails to bind its port, but `ss` shows nothing on it

a wildcard bind (`0.0.0.0:53`, etc.) can fail with `address already in use`
even when `ss -tulnp` shows no literal `0.0.0.0:port` entry — only a
*specific*-address socket on the same port (e.g. `127.0.0.53:53`). linux
rejects a later wildcard bind if any earlier bind already holds that exact
port on a specific address, regardless of which address. the reverse order
(wildcard bound first, specific address bound after) is generally fine —
so this is order-dependent and won't always reproduce.

hit this on `foundry`: `systemd-resolved`'s stub listener held
`127.0.0.53:53`/`127.0.0.54:53`, which blocked AdGuardHome's `0.0.0.0:53`
bind whenever `resolved` happened to restart before `adguardhome` during
activation. see the `services.resolved.settings.Resolve.DNSStubListener`
comment in [`modules/foundry.nix`](../modules/foundry.nix) for the fix —
disable the stub listener on any host where another service needs the
whole port.

**fix:** find what's holding a *specific* address on the port
(`sudo ss -tulnp | grep :<port>`), not just the wildcard address, before
assuming the port is free.

## every `nix` build fails with `opening file "/run/secrets/nix_signing_key": No such file or directory`

`modules/hoss-builder.nix` sets `nix.settings.secret-key-files` to a `sops-nix`
secret path so hoss signs the store paths it builds for the rest of the fleet.
if `sops-install-secrets` fails during activation, `/run/secrets/` is never
created, that file goes missing, and `nix` then refuses **every** local build —
including the `nixos-rebuild` that would fix the config. a bootstrap deadlock.

`sops-install-secrets` validates the whole manifest up front and aborts all of
it on the first problem. the usual cause is a secret whose `owner`/`group`
names a user that doesn't exist in the current system:

```
sops-install-secrets: manifest is not valid: failed to lookup user 'green'
Activation script snippet 'setupSecrets' failed (1)
```

hit this on hoss: `modules/hoss-sops.nix` declared `green_db_password` and the
`green-env` template as `owner = "green"`, but the `green` user only exists when
`services.green.enable` is true (`modules/hoss-green.nix`, off by default). the
fix there gates the ownership on `config.services.green.enable` and falls back
to root otherwise.

**recovery** (two steps — the config fix alone can't apply itself):

1. fix the offending `owner`/`group` (or whatever failed manifest validation —
   check `journalctl -b | grep -A1 'setting up secrets'`).
2. `just rescue-switch` — rebuilds once with `--option secret-key-files ''` so
   the build isn't blocked by the missing key. activation then repopulates
   `/run/secrets/`, and plain `just switch` works again.

check `ls /run/secrets/` afterwards; `mkcert-shared` also reissues the host
certs on its own once `ca_key` is back.

## ssh one-liners with bash syntax fail on hosts where the login shell is `nu`

`chrash`'s login shell is `nu` (nushell) on most hosts, including `foundry`.
`ssh host 'cmd1; cmd2 2>&1 | grep ...'` sends that whole string to the
*remote* login shell — if it's `nu`, bash-only syntax (`2>&1`, `$0`, `$$`,
etc.) fails to parse:

```
Error: nu::parser::shell_outerr
The '2>&1' shell operation is 'out+err>' in Nushell.
```

**fix:** either use `nu`-native syntax for the remote command, or force bash
explicitly and keep the script a single quoted argument so it survives
ssh's argv-join step:

```bash
ssh host -- bash -c 'cmd1; cmd2 2>&1 | grep ...'
```

simpler still: avoid compound one-liners over ssh and run each diagnostic
command separately.
