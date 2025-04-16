
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

# List all available network interfaces in a nushell-friendly table
export def "net interfaces" [] {
    # Different approach based on OS
    if (sys host).name == "Darwin" {
        # macOS approach
        run-external "ifconfig" "-a"
        | lines
        | where {|line| $line | not ($in | str starts-with "\t") }
        | where {|line| $line | str contains ":" }
        | each {|line|
            let parts = $line | split row ":"
            let iface = $parts.0 | str trim
            {
                interface: $iface,
                status: (run-external ifconfig $iface | lines | parse --regex "status: (?<status>[^\n]+)" | get status | default ["inactive"] | first)
            }
        }
        | where interface != "lo0"  # Filter out loopback
        | sort-by interface
    } else {
        # Linux approach
        run-external "ip" "link" "show"
        | lines
        | where {|line| $line | str contains "state" }
        | parse -r '\d+:\s+([^:]+):[^<]+<([^>]+)>.*state\s+(\w+)'
        | rename interface flags state
        | update flags {|row| $row.flags | split row "," | str trim }
        | where interface != "lo"  # Filter out loopback
        | sort-by interface
    }
}

# Get the primary active network interface
def get-primary-interface [] {
    let interfaces = net interfaces

    # Get active interfaces first
    let active = $interfaces
        | where (
            if "status" in ($interfaces | columns) {
                status == "active"
            } else {
                state == "UP"
            }
        )

    # Try to find a non-virtual, non-Docker interface
    let primary = $active
        | where {|iface|
            not ($iface.interface | str contains "docker") and not ($iface.interface | str contains "veth") and not ($iface.interface | str contains "br")
        }
        | first

    if ($primary | length) > 0 {
        $primary.interface
    } else if ($active | length) > 0 {
        # Fall back to any active interface
        $active.interface.0
    } else {
        # Last resort: just use the first non-loopback interface
        $interfaces.interface.0
    }
}

# Get subnet from an interface (e.g., 192.168.1.0/24)
def get-subnet [interface: string] {
    if (sys).host.name == "Darwin" {
        # macOS approach
        let ip_info = (run-external ifconfig $interface
            | lines
            | where {|line| $line | str contains "inet " }
            | first)

        if ($ip_info | is-empty) {
            "192.168.1.0/24"  # fallback
        } else {
            let ip = ($ip_info | parse -r 'inet\s+([0-9.]+)' | get capture0 | first)
            let netmask = ($ip_info | parse -r 'netmask\s+0x([0-9a-f]+)' | get capture0 | first)

            # Convert hex netmask to CIDR notation
            let hex_to_cidr = {
                "ff000000": "/8",
                "ffff0000": "/16",
                "ffffff00": "/24",
                "ffffffff": "/32"
            }

            let cidr = $hex_to_cidr | get $netmask "24"
            let subnet_prefix = $ip | split row "." | take 3 | str join "."
            $"($subnet_prefix).0($cidr)"
        }
    } else {
        # Linux approach
        let ip_info = (run-external ip addr show $interface
            | lines
            | where {|line| $line | str contains "inet " }
            | first)

        if ($ip_info | is-empty) {
            "192.168.1.0/24"  # fallback
        } else {
            $ip_info | parse -r 'inet\s+([0-9.]+/[0-9]+)' | get capture0 | first
        }
    }
}

# Get all devices on the network using various methods with fallback mechanisms
export def "net devices" [
    --interface: string         # Specify network interface (e.g., en0, wlan0)
    --method: string = "auto"   # Scanning method: auto, arp, nmap, or ping
    --format: string = "table"  # Output format (table, json)
] {
    # Determine interface if not specified
    let interface_arg = if $interface == null {
        get-primary-interface
    } else {
        $interface
    }

    print $"Using interface: ($interface_arg)"

    # Get the subnet for the interface
    let subnet = get-subnet $interface_arg
    print $"Scanning subnet: ($subnet)"

    # Choose scanning method based on user preference or fall back as needed
    let method = if $method == "auto" {
        # Try arp first, fall back to others if it fails
        try {
            run-external "sudo" "arp-scan" "--localnet" "--interface" $interface_arg "-N" | ignore
            "arp"
        } catch {
            try {
                run-external "nmap" "-sn" $subnet "-n" | ignore
                "nmap"
            } catch {
                "arp-table"
            }
        }
    } else {
        $method
    }

    print $"Using scanning method: ($method)"

    # Scan based on the selected/determined method
    let devices = if $method == "arp" {
        # ARP scanning method
        run-external "sudo" "arp-scan" "--localnet" "--interface" $interface_arg
        | lines
        | skip 2  # Skip header lines
        | where {|line| not ($line | str contains "packets") } # Filter out summary lines
        | where {|line| not ($line | is-empty) }
        | parse "{ip}\t{mac}\t{manufacturer}"
        | update manufacturer {|dev|
            if ($dev.manufacturer | is-empty) {
                "Unknown"
            } else {
                $dev.manufacturer | str trim
            }
        }
    } else if $method == "nmap" {
        # Nmap scanning method - good fallback that often requires fewer permissions
        run-external "nmap" "-sn" $subnet
        | lines
        | window 2
        | each {|window|
            let ip_line = $window | where {|line| $line | str contains "Nmap scan report" } | first
            let mac_line = $window | where {|line| $line | str contains "MAC Address" } | first

            if ($ip_line | is-empty) {
                null
            } else {
                let ip = $ip_line | parse "Nmap scan report for {ip}" | get ip | first

                if ($mac_line | is-empty) {
                    {ip: $ip, mac: "Unknown", manufacturer: "Unknown"}
                } else {
                    let mac_info = $mac_line | parse "MAC Address: {mac} ({manufacturer})"
                    {
                        ip: $ip,
                        mac: $mac_info.mac.0,
                        manufacturer: $mac_info.manufacturer.0
                    }
                }
            }
        }
        | where {|entry| $entry != null }
    } else {
        # Last resort: use the system's ARP table
        run-external "arp" "-a"
        | lines
        | parse -r '(?:([^(]+) )?\(([^)]+)\) at ([a-f0-9:]+)(?: \[([^\]]+)\])?(?: on ([^ ]+))?'
        | rename hostname ip mac type interface
        | update hostname {|row| if ($row.hostname | is-empty) { "Unknown" } else { $row.hostname | str trim } }
        | update type {|row| if ($row.type | is-empty) { "Unknown" } else { $row.type } }
        | update manufacturer {|row| "Unknown" }
        | select ip mac hostname manufacturer interface type
        | where mac != "ff:ff:ff:ff:ff:ff"  # Filter out broadcast
    }

    # Return formatted output based on preference
    if $format == "json" {
        $devices | to json
    } else {
        $devices
    }
}

# Get details about a specific device by IP address
export def "net device" [
    ip: string  # IP address of the device to query
] {
    net devices
    | where ip == $ip
}

# Fix for the permission issue
export def "net fix-permissions" [] {
    print "Attempting to fix BPF device permissions..."
    run-external sudo chmod 644 /dev/bpf*
    print "Permission fix applied. Try running net devices again."
}
