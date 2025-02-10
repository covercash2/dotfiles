def "disk list" [] {
	lsblk --json | from json | get blockdevices | reject type rm ro
}

def disk [
	name: string
] {
	disk list | where name == $name
}
