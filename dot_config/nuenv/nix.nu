const DEFAULT_NIXOS_DIR = "/home/chrash/nixos"

def "nixos rebuild" [
	config_dir: path = DEFAULT_NIXOS_DIR
] {
	sudo 
}
