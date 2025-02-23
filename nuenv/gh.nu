# GitHub helpers with the `gh` command

# get all Rust repositories using gh
export def "gh repos rust" [
  --org: string # the organization to search
] {
  (^gh repo list
    $org
    --language Rust
    --no-archived
    --json "name,description,url,updatedAt"
  )
}
