# Secrets management for the dotfiles repo.
#
# Secrets are stored per-host in secrets/<host>.yaml, encrypted with rops
# using each host's SSH ed25519 key converted to an age key.
# See docs/secrets.md for full background.
#
# rops discovers age private keys via the ROPS_AGE environment variable.
# These commands derive that key from the SSH host key via ssh-to-age (requires
# sudo) and pass it to rops via with-env.
#
# Requirements:
#   - ssh-to-age must be in system packages (it is: see modules/green.nix)
#   - sudo access (to read /etc/ssh/ssh_host_ed25519_key)
#   - For hoss commands: must run on hoss (needs hoss's SSH host key)
#
# Usage:
#   overlay use sops.nu
#   secrets list                        # show all secret key names (green, current host)
#   secrets list --host hoss            # show hoss secrets (run on hoss)
#   secrets add miniflux_admin_password # prompt for value and save it
#   secrets init --host hoss nix_signing_key --file /tmp/key.sec  # create new secrets file

const REPO     = "~/github/covercash2/dotfiles"
const SSH_HOST_KEY = "/etc/ssh/ssh_host_ed25519_key"

const HOST_PUBKEYS = {
  green: "age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96"
  hoss:  "age19cvlxe3me22hpqrlpz5l7mnz3ayhx3z2w5dcxlmkl833e0zk94zqgt5yxl"
}

def secrets_file [host: string] {
  $"($REPO)/secrets/($host).yaml" | path expand
}

def host_pubkey [host: string] {
  let key = ($HOST_PUBKEYS | get -o $host)
  if $key == null {
    error make { msg: $"unknown host '($host)'. known hosts: ($HOST_PUBKEYS | columns | str join ', ')" }
  }
  $key
}

# Derive the age private key from the local SSH host key.
# Requires sudo — prompts for password interactively.
def derive_age_key [] {
  let key = (^sudo ssh-to-age -private-key -i $SSH_HOST_KEY | str trim)
  if ($key | is-empty) or not ($key | str starts-with "AGE-SECRET-KEY-") {
    error make { msg: $"ssh-to-age produced unexpected output: ($key)" }
  }
  $key
}

# Run the given closure with ROPS_AGE set to the derived age private key.
def with_age_key [action: closure] {
  with-env {ROPS_AGE: (derive_age_key)} {
    do $action
  }
}

# Print help for secrets subcommands.
export def secrets [] {
  print "secrets — manage sops-encrypted secrets in secrets/<host>.yaml"
  print ""
  print "subcommands:"
  print "  secrets list [--host <h>]          show all secret key names (requires sudo on target host)"
  print "  secrets get <key> [--host <h>]     print the value of a secret (requires sudo on target host)"
  print "  secrets add <key> [--host <h>]     add or update a secret (requires sudo on target host)"
  print "  secrets init <key> --host <h>      create a new secrets file (public key only, no sudo needed)"
  print "  secrets edit [--host <h>]          open the file in \$EDITOR interactively (requires TTY)"
  print ""
  print $"known hosts: ($HOST_PUBKEYS | columns | str join ', ')"
}

# List the names of all secrets in the encrypted file. Requires sudo.
export def "secrets list" [
  --host: string = "green"  # which host's secrets file to read
] {
  let path = (secrets_file $host)
  with_age_key {
    ^rops decrypt $path | from yaml | columns
  }
}

# Add or update a secret. Prompts for the value without echoing. Requires sudo.
# Use --file to read the value from a file path instead (preserves newlines, useful for keys).
export def "secrets add" [
  key: string         # name of the secret to add or update
  --host: string = "green"  # which host's secrets file to update
  --file: path        # read value from this file instead of prompting
] {
  let value = if $file != null {
    open --raw ($file | path expand)
  } else {
    let v = (input --suppress-output $"value for '($key)': ")
    print ""
    $v
  }
  let path = (secrets_file $host)
  let pubkey = (host_pubkey $host)

  # Decrypt → merge → re-encrypt. Re-encrypt only needs the public key.
  let updated = (with_age_key { ^rops decrypt $path | from yaml } | upsert $key $value)

  $updated
  | to yaml
  | ^rops encrypt --age $pubkey -f yaml
  | save --force $path

  print $"saved '($key)' to ($path)"
}

# Create a new secrets file for a host. Only needs the host's public key — no sudo required.
# Use this to bootstrap a host's secrets file from any machine.
export def "secrets init" [
  key: string         # first secret key to add
  --host: string      # which host to create the secrets file for (required)
  --file: path        # read value from this file instead of prompting
] {
  if $host == null {
    error make { msg: "--host is required for secrets init" }
  }
  let path = (secrets_file $host)
  if ($path | path exists) {
    error make { msg: $"($path) already exists — use 'secrets add --host ($host)' to add more secrets" }
  }
  let pubkey = (host_pubkey $host)
  let value = if $file != null {
    open --raw ($file | path expand)
  } else {
    let v = (input --suppress-output $"value for '($key)': ")
    print ""
    $v
  }

  {$key: $value}
  | to yaml
  | ^rops encrypt --age $pubkey -f yaml
  | save --force $path

  print $"created ($path) with key '($key)'"
}

# Get the value of a secret. Requires sudo.
export def "secrets get" [
  key: string                   # name of the secret to retrieve
  --host: string = "green"      # which host's secrets file to read
] {
  let path = (secrets_file $host)
  with_age_key {
    ^rops decrypt $path | from yaml | get $key
  }
}

# Open the secrets file interactively using $EDITOR. Requires a TTY.
export def "secrets edit" [
  --host: string = "green"  # which host's secrets file to edit
] {
  with_age_key {
    ^rops edit (secrets_file $host)
  }
}
