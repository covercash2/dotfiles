# explore a JSON file using neovim and jq
def "json explore" [
	file: path # a JSON file to open
]: [] {
	let args = $'+"JqPlayground ($file)"'
	run-external nvim $args
}
