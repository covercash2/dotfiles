# Nushell Environment Config File
# this file is sourced _before_ `config.nu`

$env.STARSHIP_SHELL = "nu"

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($env.HOME | path join ".config/nushell/scripts")
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

$env.user_paths = ([
	"bin",
	".cargo/bin",
	".local/bin",
	".asdf/bin",
	"google-cloud-sdk/bin",
	"go/bin"
] | each {|path| $nu.home-path | path join $path })

$env.PATH =	($env.PATH | prepend ($env.user_paths | where $it not-in $env.PATH))

if (which zoxide | is-empty) {
	print "zoxide not found"
} else {
	zoxide init nushell | save --force ~/.zoxide.nu
}

if (which nvim | is-empty) {
	print "nvim not found"
} else {
	$env.EDITOR = (which nvim | get path.0)
}

if (which ov | is-empty) {
	print "ov pager not found"
} else {
	$env.PAGER = (which ov | get path.0)
}

# filter null keys
def "compact keys" [
  --empty(-e) # filter empty keys as well as null
]: record -> record {

  let fn = if $empty {
    {|rc| $rc.value | is-not-empty }
  } else {
    {|rc| $rc.value != null }
  }

  $in
  | transpose key value
  | filter $fn
  | transpose -rd
}
