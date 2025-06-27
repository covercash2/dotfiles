# wake on LAN functions
use secrets.nu *

export def wake [
  host: string
  --debug
] {
  let mac = mac $host
  let args = [
    "wol"
    $mac
  ]

  if $debug {
    print $args
  }

  run-external ...$args
}

export def "vpn ips" [
  host?: string
] {
  tailscale status --json
  | from json
  | get Peer
  | transpose
  | get column1
  | select HostName TailscaleIPs
  | if $host == null {
      $in
    } else {
      $in | where HostName == $host
    }
  | rename host IPs
  | update IPs {|row|
      let v4 = $row.IPs.0
      let v6 = $row.IPs.1
      { IPv4: $v4, IPv6: $v6 }
    }
}
