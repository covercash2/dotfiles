const DEFAULT_NIXOS_DIR = "/home/chrash/.local/share/chezmoi/nixos"

def "nixos rebuild" [
	config_name?: string
	--config_dir: path = $DEFAULT_NIXOS_DIR
] {
	let config_name = if $config_name == null {
		run-external hostname
	} else {
		$config_name
	}
	let config_name = $"#.($config_name)"
	cd $config_dir
	let command = [
		nixos-rebuild
		switch
		"--flake"
		$config_name
		"--show-trace"
	]

	ls | inspect
	print $command
	run-external sudo ...$command
}
