const INITIAL_STATE = {
  container_id: ''
}

export def "podman state path" [] {
  "~/.local/state/nuenv/podman.toml" | path expand
}

export def "podman state" [] {
  open (podman state path)
}

# execute a bash command with `podman`
export def "podman bash" [
  --user: string
  --container_id: string = "" # the name or hash of the container to run this command in
  cmd: string # the text of the command
] {
  podman state check

  let env_id = podman container previous

  if $env_id == '' and $container_id == '' {
    error make { msg: $'container ID not found in (podman state path). provide a container ID for the first run' }
  }

  let id = if $env_id == '' {
    print $'setting new $env.container_id to ($container_id)'
    podman state set_id $container_id
    $container_id
  } else if $container_id != '' {
    print $'updating container id from ($env_id) to ($container_id)'
    podman state set_id $container_id
    $container_id
  } else {
    $env_id
  }

  podman exec $id /bin/bash -c $cmd
}

export def "podman state check" [] {
  let path = podman state path
  if not ($path | path exists) {
    print $"creating initial podman state at ($path | path dirname)"
    $path
    | path dirname
    | mkdir -v $in

    $INITIAL_STATE | save $path
  }
}

# set a container to be used in subsequent commands
export def "podman state set_id" [
  container_id: string
] {
  podman state check

  podman state
  | update container_id $container_id
  | save --force (podman state path)
}

# get previously set container
export def "podman container previous" [] {
  podman state check
  podman state | get container_id
}
