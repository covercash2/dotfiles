
# get ports
export def "net ports" [] {
	let raw = run-external "netstat" "-vanp" "tcp"
# skip first line
	let lines = $raw | lines | skip 1 | str join "\n" | detect columns

	$lines
}

export def "net port" [
	port: string
] {
	net ports
	| where {|x| $x.Local | str ends-with $port }
}

