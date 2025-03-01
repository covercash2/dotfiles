# a wrapper around the `sed` command that makes it easier to use in nushell
# for example, this command replaces ServiceCall<ServiceCallSetup> with ServiceCall
# in a Rust project:
# ````
# sed -i "" 's/ServiceCall<ServiceCallSetup>/ServiceCall/g' crates/**/*.rs
# ````
# this command is a bit tough to parse, and so we provide a nicer interface here.
# for example:
# ```
# sed --pattern "ServiceCall<ServiceCallSetup>" --replace "ServiceCall" --dir "crates/**/*.rs"
export def replace [
  pattern: string # the pattern to search for
  --with: string # replaces the pattern
  --files: glob # the directory to search in (glob)
] {
  # the `-i` flag is necessary on macOS
  # https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux
  run-external sed "-i.bak" $"s/($pattern)/($with)/g" $files
}

# the `replace` command creates a lot of `.bak` files.
# this command cleans up those files
export def "replace confirm" [
  --verbose # if true, prints the files that are being deleted
] {
  ls -al **/*.bak
  | each {
    if $verbose {
      print $"deleting file: ($in.name)"
    }
    rm $in.name
  }
}
