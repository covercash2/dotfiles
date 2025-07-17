# the default overlay
# this overlay contains aliases for common system commands like ls, cp, etc.

export alias ls = ls -a
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
