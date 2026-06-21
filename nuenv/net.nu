const ARP_FORMAT_REGEX = '^(?<domain>\S+) \((?<IP_addr>.+)\) at (?<HW_addr>\S+) on (?<interface>\S+) (?<extra>.*) \[(?<type>\S+)\]$'

# a placeholder to autocomplete subcommands
export def main [] {
  "a placeholder to autocomplete subcommands"
}

# dump arp cache
export def "net known-devices" [] {
  (shell --verbose "arp" "-a"
  | lines
  | each {|line|
      $line
      | str trim
      # | describe
      | parse --regex '^(?<domain>\S+) \((?<IP_addr>.+)\) at (?<HW_addr>\S+) on (?<interface>\S+) (?<extra>.*) \[(?<type>\S+)\]$'
    }
  | flatten
  )
}

# sweep an IP address range to discover devices
export def "net sweep" [
  address: string # the first 3 bytes of the root address
] {
  1..25 | par-each {|n|
    let ip = $"($address).($n)"
    print $"> ($ip)"
    shell -v ping "-c" "1" "-W" "30" $ip
    | each {|o| print $o }
  }
}

# get ports
export def "net ports" [] {
	let raw = run-external "netstat" "-vanp" "tcp"
# skip first line
	let lines = $raw | lines | skip 1 | str join "\n" | detect columns

	$lines
}

export def "net connections" [
  --port: int
] {
  let args = if $port != null {
    ["-i", $":($port)"]
  } else {
    ["-i"]
  }

  let args = $args ++ ['-n' '-P']

  print $args

  let raw = run-external "lsof" ...$args

  $raw | detect columns
}

export alias "net conn" = net connections

export def "net port" [
	port: string
] {
	net ports
	| where {|x| $x.Local | str ends-with $port }
}

# get the default gateway
export def "net gateway" [] {
  (shell --verbose "route" "-n" "get" "default"
  | lines
  | each {|line| $line | str trim }
  | where {|line| $line | str contains ": " }
  | parse "{key}: {value}"
  | reduce --fold {} {|row, acc| $acc | insert $row.key $row.value }
  | select gateway interface
  )
}

export def "net interfaces" [] {
  let raw = run-external "ifconfig" "-a"

  let interfaces = $raw | lines | reduce {|acc, line|
    if ($line | str starts-with " ") {
      # parse interface data
      let line = $line | str trim
      netstat -i4n --libxo json
    } else {
      # parse first interface line
      let words = $line | split words
      let interface_name = $words | get 0 | str substring 0..-1
      let flags = $words | get 1
      let mtu = $words | get 3

      {
        name: $interface_name
        flags: $flags
        mtu: $mtu
      }
    }
  }
}

def os_name [] {
  uname | get kernel-name
}

def kernel_names [] {
  ["Darwin", "Linux"]
}

def shell [
  --verbose,-v
  ...args
] {
  if $verbose {
    print $"(ansi white_bold)$ ($args | str join ' ')(ansi reset)"
  }

  run-external $args
}
