
export def "cargo backtrace" [
  cargo_command: string,
] {
  with-env {
    RUST_BACKTRACE: 1
  } {
    run-external cargo $cargo_command
  }
}

# run the project and collect logs,
# rejecting fields that are not important for local dev
export def "logs filter" [] {
  lines
  | each {|line|
    $line
    | try {
        from json
        | default "∅" error
        | (select
            timestamp
            level
            message
            error
            span_name
            target
          )
        | update timestamp {|row| $row.timestamp | into datetime }
      } catch {
        # if JSON fails to parse, just return the line as is
        print $in
      }
    }
}
