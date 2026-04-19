# Digital Ocean droplet utilities
#
# The DO metadata API (http://169.254.169.254) is accessible from inside a
# droplet even before DHCP completes — it speaks over link-local so it works
# as soon as the NIC is up. Useful for recovery when DHCP fails on boot.
#
# Network recovery workflow (run on the droplet console):
#   1. `do metadata` to get IP, gateway, netmask
#   2. `do network up <iface>` to configure the interface manually
#   3. ssh in and run `nixos-rebuild switch`

const METADATA_BASE = "http://169.254.169.254/metadata/v1"

# Fetch all droplet metadata as a record
export def "do metadata" [] {
    http get $"($METADATA_BASE).json"
}

# Get the public IPv4 address of this droplet
export def "do metadata ip" [] {
    http get $"($METADATA_BASE)/interfaces/public/0/ipv4/address"
}

# Get the public IPv4 gateway
export def "do metadata gateway" [] {
    http get $"($METADATA_BASE)/interfaces/public/0/ipv4/gateway"
}

# Get the public IPv4 netmask (e.g. 255.255.240.0 = /20)
export def "do metadata netmask" [] {
    http get $"($METADATA_BASE)/interfaces/public/0/ipv4/netmask"
}

# Get the droplet hostname
export def "do metadata hostname" [] {
    http get $"($METADATA_BASE)/hostname"
}

# Bring up a network interface using metadata from the DO API.
# Run this on the droplet console when DHCP fails (e.g. after a fresh NixOS
# install before `networking.useDHCP` takes effect on the running system).
#
# Example:
#   do network up ens3
export def "do network up" [
    iface: string  # network interface name, e.g. ens3
] {
    let ip      = do metadata ip
    let gateway = do metadata gateway
    let netmask = do metadata netmask

    # Convert dotted netmask to CIDR prefix length
    let prefix = $netmask
        | split row "."
        | each { into int | into bits | split chars | where { $in == "1" } | length }
        | math sum

    print $"Interface : ($iface)"
    print $"IP        : ($ip)/($prefix)"
    print $"Gateway   : ($gateway)"
    print ""

    run-external sudo ip addr add $"($ip)/($prefix)" dev $iface
    run-external sudo ip route add default via $gateway
    run-external sudo bash "-c" $"echo 'nameserver 1.1.1.1' > /etc/resolv.conf"

    print "Network configured. Test with: ping -c 3 1.1.1.1"
}

# Show a summary of public network info for this droplet
export def "do network info" [] {
    let meta = do metadata

    {
        hostname: ($meta | get hostname? | default "unknown")
        ip:       ($meta | get interfaces?.public?.0?.ipv4?.ip_address? | default "unknown")
        gateway:  ($meta | get interfaces?.public?.0?.ipv4?.gateway? | default "unknown")
        netmask:  ($meta | get interfaces?.public?.0?.ipv4?.netmask? | default "unknown")
    }
}
