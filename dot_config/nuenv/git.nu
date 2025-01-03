
let delimeter = "✨"
let short_hash = "%h"
let message = "%s"
let author = "%aN"
let email = "%aE"
let date = "%aD"

let default_columns = [
	{
		name: "short_hash",
		pattern: $short_hash,
	},
	{
		name: "message",
		pattern: $message,
	},
	{
		name: "author",
		pattern: $author,
	},
	{
		name: "email",
		pattern: $email,
	},
	{
		name: "date",
		pattern: $date,
	},
]

def derive_pattern [
	columns?: table
] {
	let input = if $columns == null {
		$default_columns
	} else {
		$columns
	}
	$input | get pattern | str join $delimeter
}

def derive_names [
	columns?: table
] {
	let input = if $columns == null {
		$default_columns
	} else {
		$columns
	}

	$input | get name
}

def "git log" [
	--lines: int = 100 # see git log -n
] {
	let columns = $default_columns
	let pattern = derive_pattern $columns
	let column_names = derive_names $columns
	let raw = run-external "git" "log" "-n" $lines $"--pretty=($pattern)"
	let raw_table = $raw | lines | split column $delimeter | rename ...$column_names
	let with_date = $raw_table | upsert date {|d| $d.date | into datetime }

	let output = $with_date

	$output
}

# format a branch name with a date suitable for filenames
def "git branch filename" [] {
	let branch = (git branch --show-current) | str replace --all '/' '.'
	$'($branch)_(date now | format date "%Y-%m-%d_%H:%M:%S")'
}

def "git find" [
	search_dir: path = ~
] {
	fd -H ^\.git$ ($search_dir | path expand)
	| lines
	| path dirname
	| path relative-to ~
}

def "git find outdated" [
	search_dir: path = ~
] {
	git find
}
