export def sysd [
	service?: string@"sysd services"
] {
	if $service == null {
		systemctl
	} else {
		let args = [
			status
      "--no-pager"
			$service
		]

		run-external systemctl ...$args
	}
}

export def "sysd unit-types" [] {
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
export def "sysd list-units" [] {
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

export def "sysd services" [] {
	sysd list-units
	| where {|unit| $unit.type == service}
}

export def "sysd service_names" [] {
	sysd services
	| get name
}

export def "sysd logs" [
	service_name: string@"sysd service_names"
	--lines: int = 100 # number of entries to show
] {
	let args = [
		journalctl
		--catalog # show extra explanations where available
		$"--lines=($lines)" # number of entries to show
		--no-pager
		--output=json
		--unit $service_name]

	run-external sudo ...$args
	| lines
	| each {|line| $line | from json }
}

# print the user information for a systemd service
export def "sysd user" [
  service_name: string@"sysd service_names"
] {
  let output = systemctl show -pUser,UID $service_name

  # output is like:
  # User=zwavejs-ui
  # UID=1001

  ($output
    # split lines into a record
    | lines
    | each {|line| $line
      | split row "="
      | { $in.0: $in.1 }
    }
    | reduce {|it| merge $it}
  )
}
