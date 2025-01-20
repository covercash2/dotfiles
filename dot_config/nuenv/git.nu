
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

def "git remote open" [
	remote_name: string = "origin"
] {
	let url = git remote get-url $remote_name | ssh to http
	print opening $url
	run-external open $url
}

def "ssh to http" []: [string -> string] {
	if not ($in | str starts-with "git@") {
		error make {
			msg: $"did not recognize address as a git SSH address: $($in)",
			help: "run `git remote get-url <repo>` to get your local remote address",
		}
	}

	let data = $in | parse "git@{url}:{user}/{repo}.git"

	$"https://($data.0.url)/($data.0.user)/($data.0.repo)"
}
