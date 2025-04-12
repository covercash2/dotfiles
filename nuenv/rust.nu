
export def "cargo backtrace" [
  cargo_command: string,
] {
  with-env {
    RUST_BACKTRACE: 1
  } {
    run-external cargo $cargo_command
  }
}
