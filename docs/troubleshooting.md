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
