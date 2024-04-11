
# get ports
def "net ports" [] {
	let raw = run-external --redirect-stdout "netstat" "-vanp" "tcp"
# skip first line
	let lines = $raw | lines | skip 1 | str join "\n" | detect columns

	$lines
}
