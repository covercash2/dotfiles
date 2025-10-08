
const delimiter = "✨"
const short_hash = "%h"
const message = "%s"
const author = "%aN"
const email = "%aE"
const date = "%aD"

const default_columns = [
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
	$input | get pattern | str join $delimiter
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

export def "git log" [
	--lines: int = 100 # see git log -n
] {
	let columns = $default_columns
	let pattern = derive_pattern $columns
	let column_names = derive_names $columns
	let raw = run-external "git" "log" "-n" $lines $"--pretty=($pattern)"
	let raw_table = $raw | lines | split column $delimiter | rename ...$column_names
	let with_date = $raw_table | upsert date {|d| $d.date | into datetime }

	let output = $with_date

	$output
}

export def "git trigger-ci" [] {
  run-external "git" "commit" "--allow-empty" "-m" "chore: trigger CI"
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

export def "git remote open" [
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

export const git_statuses = {
  "M": {
    color: "yellow",
    label: "modified ✎",
  }
  "A": {
    color: "green_bold",
    label: "added ✢",
  }
  "D": {
    color: "red_bold",
    label: "deleted ✕",
  }
  "R": {
    color: "yellow_bold",
    label: "renamed ☛",
  }
  "??": {
    color: "purple",
    label: "untracked ☉",
  }
}

def render_git_status [
  --status: string # the status symbol emitted by git status --porcelain
  --file: string # the file path emitted by git status
  --status_map: record = $git_statuses
] {
  let status = $status_map | get --optional $status | default ($status_map | get "??")
  let color = $status.color

  let status_label = $"(ansi $color)($status.label)(ansi reset)"
  let file_label = $"(ansi $color)($file)(ansi reset)"

  { status: $status_label, file: $file_label }
}

# return `git status` as a list
export def "git status" [] {
  ^git status --porcelain
  | lines
  | each {|line|
    $line
    | str trim
    | parse '{status} {file}'
    | each {|row|
      render_git_status --status $row.status --file $row.file
    }
  }
  | if ($in | is-empty) {
      "already up-to-date"
    } else {
      $in | reduce {|elt, acc| $acc ++ $elt }
    }
}

# ammend a commit
export def "git ammend" [] {
  external git add "--all"
  external git commit "--amend"
}

# run an external command with some personal tweeks
def "external" [
  command: string
  ...args: string
] {
  print $"running `($command)` with ($args)"
  run-external $command ...$args
}
