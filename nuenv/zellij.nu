# Zellij session management wrappers.

def session-names [] {
    zellij list-sessions --no-formatting --short
        | lines
        | str trim
}

def layout-names [] {
    let layout_dir = ($env.HOME | path join ".config/zellij/layouts")
    if ($layout_dir | path exists) {
        ls $layout_dir
            | where name =~ '\.kdl$'
            | get name
            | each { path basename | str replace '.kdl' '' }
    } else {
        []
    }
}

# List active zellij sessions
export def "zj ls" [] {
    zellij list-sessions
}

# Attach to a session by name
export def "zj attach" [
    name: string@session-names  # Session name
] {
    zellij attach $name
}

# Create a new named session, optionally with a layout
export def "zj new" [
    --name (-s): string   # Session name
    --layout (-l): string@layout-names # Layout name
] {
    if ($layout | is-not-empty) {
        let args = if ($name | is-not-empty) {
            [--new-session-with-layout $layout --session $name]
        } else {
            [--new-session-with-layout $layout]
        }
        run-external zellij ...$args
    } else if ($name | is-not-empty) {
        zellij --session $name
    } else {
        zellij
    }
}

# Kill a session by name
export def "zj kill" [
    name: string@session-names  # Session name
] {
    zellij kill-session $name
}

# Kill all sessions
export def "zj kill-all" [] {
    zellij kill-all-sessions
}

# Attach to a session if it exists, otherwise create it (optionally with a layout)
export def "zj open" [
    name: string          # Session name
    --layout (-l): string@layout-names # Layout to use when creating
] {
    let exists = (session-names | any { $in == $name })
    if $exists {
        zellij attach $name
    } else {
        zj new --name $name --layout $layout
    }
}
