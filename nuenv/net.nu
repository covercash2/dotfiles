
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
