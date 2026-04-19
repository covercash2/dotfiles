# Hardware configuration for the foundry Digital Ocean KVM VPS
#
# BOOT: SeaBIOS (BIOS/legacy), confirmed from boot screen output.
#   - systemd-boot rejected: EFI-only, won't work with SeaBIOS.
#   - GRUB with efiSupport rejected: same reason.
#   - GRUB with `device` (singular) rejected: triggers "duplicated devices in
#     mirroredBoots" assertion when combined with qemu-guest.nix defaults.
#   - Current: GRUB with `devices` (plural) + qemu-guest.nix — builds cleanly.
#
# DISK: /dev/vda (virtio block device, standard for DO KVM droplets).
#   Partition layout defined in modules/foundry-disk.nix via disko.
#   GPT with a 1M EF02 BIOS boot partition (required for GRUB on GPT/BIOS).
#   2G swap partition added to prevent OOM during nixos-anywhere installation.
{ modulesPath, ... }:

{
  # Provides virtio drivers, qemu-guest-agent, and other KVM guest defaults.
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # GRUB device config intentionally omitted — disko automatically sets
  # boot.loader.grub.devices when it finds the EF02 BIOS boot partition.
  # Setting it here too causes a "duplicated devices in mirroredBoots" assertion.
  boot.loader.grub.enable = true;
  # Disable the systemd-boot default from configuration.nix — only one
  # bootloader can be active. Foundry uses BIOS/GRUB (SeaBIOS, not UEFI).
  boot.loader.systemd-boot.enable = false;

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
