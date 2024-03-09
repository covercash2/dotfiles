use std assert

let from_string = { |s | $s | split row (char esep) | path expand --no-symlink }
let to_string = { |v| $v | path expand --no-symlink | str join (char esep)  }

let common_paths = ['/usr/bin', '/bin', '/usr/local/bin/', '/opt/homebrew/bin/']
let common_paths_string = $common_paths | str join (char esep)

#[test]
def test_path_is_valid [] {
	let left = common_paths | from_string $in
	let right = common_paths_string
	assert (left == right)
}
