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

The rebuild itself succeeds; only the CDI generator (and anything depending
on GPU passthrough to containers) is affected until the module reloads.

**Fix:** reboot the host. This is the standard remedy — it loads the kernel
module fresh against the new driver version. Unloading/reloading the nvidia
modules manually is possible but fragile on a host with active GPU users
(X, containers, etc.), so a reboot is the reliable option.
