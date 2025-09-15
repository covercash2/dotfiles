
export def "cargo backtrace" [
  cargo_command: string,
] {
  with-env {
    RUST_BACKTRACE: 1
  } {
    run-external cargo $cargo_command
  }
}

export const RUST_DEFAULT_COLUMNS = [
  timestamp
  level
  message
  error
  span_name
  target
]

export const RUST_KNOWN_COLUMNS = [
  timestamp
  level
  message
  error
  span_name
  target
  trace_id
  span_id
]

export-env {
  $env.RUST_COLUMNS = $RUST_DEFAULT_COLUMNS
}

export def --env "rust column add" [
  ...columns: string@known_columns
] {
  let updated = $env.RUST_COLUMNS ++ $columns | flatten | uniq
  export-env {
    $env.RUST_COLUMNS = $updated
  }
}

export def --env "rust column remove" [
  ...columns: string@known_columns
] {
  let updated = $env.RUST_COLUMNS | where {|col| not ($columns | any {|c| $c == $col }) }
  export-env {
    $env.RUST_COLUMNS = $updated
  }
}

export def --env "rust column reset" [] {
  export-env {
    $env.RUST_COLUMNS = $RUST_DEFAULT_COLUMNS
  }
}

def known_columns [] {
  $RUST_KNOWN_COLUMNS
}

# run the project and collect logs,
# rejecting fields that are not important for local dev
export def "logs filter" [] {
  lines --skip-empty
  | each {|line|
    $line
    | try {
        from json
        | select --optional ...$env.RUST_COLUMNS
        | update timestamp {|row|
            $row.timestamp
            | into datetime
            | date to-timezone local
            | format date '%m/%d %H%M:%S'
          }
        | print $in
      } catch {
        # if JSON fails to parse, just return the line as is
        print $in
      }
    }
}
