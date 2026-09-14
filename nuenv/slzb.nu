# SLZB-MR1U Zigbee/Z-Wave coordinator (SMLIGHT firmware, hostname `iot-radio`)
# — the network-attached radio zigbee2mqtt talks to over
# tcp://192.168.2.165:7638 (see modules/zigbee_receiver.nix).
#
# code-as-documentation for the read-only HTTP endpoints found while
# debugging why zigbee devices weren't showing up in Home Assistant.
#
# Important: this only reports on the coordinator device itself (reachable?
# recently rebooted? overheating?). It does NOT track Zigbee mesh
# topology/routing — that lives in zigbee2mqtt/zigbee-herdsman on green, not
# in the coordinator's firmware. For mesh/route health, see zigbee.nu instead.
#
# Both endpoints below are unauthenticated on the device itself.
# `slzb config` in particular returns plaintext secrets (WiFi password, admin
# credentials, VPN keys) — redacted by default, pass --raw to see everything.

const BASE = "http://192.168.2.165"

# known-sensitive fields in the /config response, redacted by default
const SENSITIVE_FIELDS = [
  [eth wbr_pass]
  [wifi pass]
  [auth pass]
  [wg privateKey]
  [wg presharedKey]
]

# Parse the device's Prometheus-style /metrics endpoint into a record
export def "slzb metrics" [] {
  http get $"($BASE)/metrics"
  | lines
  | where {|line| not ($line | str starts-with "#") and ($line | str trim | is-not-empty) }
  | parse --regex '^(?<key>[a-zA-Z_]+)\{\}\s+(?<value>[\d.]+)$'
  | reduce --fold {} {|row, acc| $acc | insert $row.key ($row.value | into float) }
}

# Human-friendly health summary for the coordinator device itself
# (not the Zigbee mesh — see the module doc comment above)
export def "slzb health" [] {
  let m = slzb metrics

  {
    uptime: (1ms * ($m.smlight_device_uptime | into int))
    temp_c: $m.smlight_device_temp
    free_heap_pct: $m.smlight_free_heap
    socket_clients: ($m.smlight_socket_clients | into int)
  }
}

# Fetch the device's full config. The endpoint is unauthenticated and returns
# secrets in plaintext, so known-sensitive fields are redacted by default —
# pass --raw to see everything (e.g. to actually recover the WiFi password).
export def "slzb config" [--raw] {
  let config = http get $"($BASE)/config"

  if $raw {
    print "warning: showing unredacted config, including plaintext secrets"
    return $config
  }

  $SENSITIVE_FIELDS | reduce --fold $config {|field, acc|
    $acc | update ($field | into cell-path) "<redacted>"
  }
}
