# the default overlay
# this overlay contains aliases for common system commands like ls, cp, etc.

export alias nu-ls = ls
export alias sys-cat = cat
export alias cat = bat

# append the --help flag to the given command
export def "help with" [
  command: string
] {
  let command = (which $command | get 0)

  print $command

  if $command.type == "external" {
    run-external $command.path "--help"
  } else {
    nu --commands $"($command.command) --help"
  }
  | bat
}

# run a nushell command with sudo
# note: `root` needs access to `nu`
export def sunu [
  ...args: string
] {
  let args = [
    sudo
    "nu --commands"
  ] ++ $args

  print $args

  run-external ...$args
}

export def "machine name" [] {
  if (which scutil | is-empty) {
    return "unknown"
  }

  let output = run-external scutil "--get" ComputerName | str trim

  if $output == "" {
    return "unknown"
  }

  return $output
}

export def "is work" [] {
  if (machine name) == "m-ry6wtc3pxk" {
    return true
  }

  return false
}

# List the filenames, sizes, and modification times of items in a directory.
# this is a wrapper that was literally copied from the docs:
# https://www.nushell.sh/book/aliases.html#replacing-existing-commands-using-aliases
def ls [
    --all (-a) = true,  # Show hidden files
    --long (-l),        # Get all available columns for each entry (slower; columns are platform-dependent)
    --short-names (-s), # Only print the file names, and not the path
    --full-paths (-f),  # display paths as absolute paths
    --du (-d),          # Display the apparent directory size ("disk usage") in place of the directory metadata size
    --directory (-D),   # List the specified directory itself instead of its contents
    --mime-type (-m),   # Show mime-type in type column instead of 'file' (based on filenames only; files' contents are not examined)
    --threads (-t),     # Use multiple threads to list contents. Output will be non-deterministic.
    ...pattern: glob,   # The glob pattern to use.
]: [ nothing -> table ] {
    let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
    (nu-ls
        --all=$all
        --long=$long
        --short-names=$short_names
        --full-paths=$full_paths
        --du=$du
        --directory=$directory
        --mime-type=$mime_type
        --threads=$threads
        ...$pattern
    ) | sort-by type name -i
}

# run neovim with the avante plugin in "Zen mode", a la Claude Code
# ```sh
# alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'
# ```
export def avante [] {
  let args = [
    nvim
    "-c"
    'lua vim.defer_fn(function()require("avante.api").zen_mode()end, 100)'
  ]

  run-external $args
}
