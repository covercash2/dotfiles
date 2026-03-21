export def "disk list" [] {
	lsblk --json | from json | get blockdevices | reject type rm ro
}

export def main [
	name: string
] {
	disk list | where name == $name
}

# Write the rescue disk ISO to a USB drive.
# Must be run on x86_64-linux — cross-flashing from macOS is not supported.
# Build the ISO first with `just build_rescue`.
#
# Example:
#   flash rescue-disk /dev/sdb
export def "flash rescue-disk" [
	device: string                               # target block device, e.g. /dev/sdb
	--iso: path = "result/iso/rescue-disk.iso"   # path to the ISO
] {
	if not ($iso | path exists) {
		error make { msg: $"ISO not found at ($iso). Run `just build_rescue` first." }
	}

	print "Available block devices:"
	disk list

	print $"\nTarget : ($device)"
	print $"ISO    : ($iso)\n"

	let confirm = (input "This will overwrite ALL data on the device. Continue? [y/N] ")
	if $confirm != "y" {
		print "Aborted."
		return
	}

	run-external sudo dd $"if=($iso)" $"of=($device)" "bs=4M" "status=progress" "conv=fsync"
}
