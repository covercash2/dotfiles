const COMPLETIONS_FILE_NAME = "asdf_completions.nu"

# get the effective data directory for asdf. usually '~/.asdf`
def "asdf data_dir" [] {
	if ( $env | get --ignore-errors ASDF_DATA_DIR | is-empty ) {
		$env.HOME | path join '.asdf'
	} else {
		$env.ASDF_DATA_DIR
	}
}

# get directory with asdf shims
let shims_dir = asdf data_dir | path join 'shims'

$env.PATH = ($env.PATH | prepend $shims_dir) | uniq

# set up completions
def "asdf completion generate" [
	data_dir: path = ~/nuenv
] {
	let completions_path = $data_dir | path join $COMPLETIONS_FILE_NAME
	asdf completion nushell | save $completions_path
}

# get the file that contains completions for nushell
def "asdf completion file" [
	data_dir: path = ~/nuenv/
] {
	$data_dir | path join $COMPLETIONS_FILE_NAME
}
