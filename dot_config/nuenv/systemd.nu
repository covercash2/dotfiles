def sysd [
	service?: string@"sysd services"
] {
	if $service == null {
		systemctl
	} else {
		let args = [
			status
			$service
		]

		run-external systemctl ...$args
	}
}

def "sysd unit-types" [] {
	[
		device
		mount
		service
		slice
		socket
		target
	]
}

# list systemd units currently in memory
def "sysd list-units" [] {
	let args = [
		systemctl
		--no-pager
		--output=json
		list-units
	]

	run-external sudo ...$args
	| from json
	| insert type {|row| $row.unit | parse --regex '.+\.(?P<type>\w+)' | get type.0 }
	| update unit {|row| $row.unit | parse --regex '(?P<name>.+)\.\w+' | get name.0 }
	| rename --column { unit: name }
}

def "sysd services" [] {
	sysd list-units
	| filter {|unit| $unit.type == service}
}

def "sysd service_names" [] {
	sysd services
	| get name
}

def "sysd logs" [
	service_name: string@"sysd service_names"
	--lines: int = 100 # number of entries to show
] {
	let args = [
		journalctl
		--catalog # show extra explanations where available
		##--pager-end # move to the end of the pager
		$"--lines=($lines)" # number of entries to show
		--no-pager
		--output=json
		--unit $service_name]

	run-external sudo ...$args
	| lines
	| each {|line| $line | from json }
}
