# Secrets management for the green dotfiles repo.
#
# Secrets are stored in secrets/green.yaml, encrypted with rops using the
# green host's SSH ed25519 key. See docs/secrets.md for full background.
#
# rops discovers age private keys via the ROPS_AGE environment variable.
# These commands derive that key from the SSH host key via ssh-to-age (requires
# sudo) and pass it to rops via with-env.
#
# Requirements:
#   - ssh-to-age must be in system packages (it is: see modules/green.nix)
#   - sudo access (to read /etc/ssh/ssh_host_ed25519_key)
#
# Usage:
#   overlay use sops.nu
#   secrets list                        # show all secret key names
#   secrets add miniflux_admin_password # prompt for value and save it

const SECRETS_FILE = "~/github/covercash2/dotfiles/secrets/green.yaml"
const AGE_PUBKEY   = "age1lvh945n6pxhwxqyrt6x5fcyvgeytnh4cg47zj2000ltmqal4xyjs0adv96"
const SSH_HOST_KEY = "/etc/ssh/ssh_host_ed25519_key"

# Derive the age private key from the SSH host key.
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
  print "secrets — manage sops-encrypted secrets in secrets/green.yaml"
  print ""
  print "subcommands:"
  print "  secrets list            show all secret key names (requires sudo)"
  print "  secrets get <key>       print the value of a secret (requires sudo)"
  print "  secrets add <key>       add or update a secret (requires sudo)"
  print "  secrets edit            open the file in \$EDITOR interactively (requires TTY)"
}

# List the names of all secrets in the encrypted file. Requires sudo.
export def "secrets list" [] {
  let path = ($SECRETS_FILE | path expand)
  with_age_key {
    ^rops decrypt $path | from yaml | columns
  }
}

# Add or update a secret. Prompts for the value without echoing. Requires sudo.
# Use --file to read the value from a file path instead (preserves newlines, useful for PEM keys).
export def "secrets add" [
  key: string       # name of the secret to add or update
  --file: path      # read value from this file instead of prompting
] {
  let value = if $file != null {
    open --raw $file
  } else {
    let v = (input --suppress-output $"value for '($key)': ")
    print ""
    $v
  }
  let path = ($SECRETS_FILE | path expand)

  # Decrypt → merge → re-encrypt. Re-encrypt only needs the public key.
  let updated = (with_age_key { ^rops decrypt $path | from yaml } | upsert $key $value)

  $updated
  | to yaml
  | ^rops encrypt --age $AGE_PUBKEY -f yaml
  | save --force $path

  print $"saved '($key)'"
}

# Get the value of a secret. Requires sudo.
export def "secrets get" [
  key: string  # name of the secret to retrieve
] {
  let path = ($SECRETS_FILE | path expand)
  with_age_key {
    ^rops decrypt $path | from yaml | get $key
  }
}

# Open the secrets file interactively using $EDITOR. Requires a TTY.
export def "secrets edit" [] {
  with_age_key {
    ^rops edit ($SECRETS_FILE | path expand)
  }
}
