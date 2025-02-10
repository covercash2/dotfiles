$env.NUENV_SRC_DIRS = ["~/.config/nuenv/"]

def "nuenv load" [
	name: string
	--dir: path
] {
	let dirs = if $dir == null {
		$env.NUENV_SRC_DIRS | path expand
	} else {
		[$dir]
	}

	let file = $dirs
		| each {|dir| ls $dir }
		| flatten
		| get name
		| find $"($name).nu"
		| first

	source $file
}
