# GitHub helpers with the `gh` command

const ENTERPRISE_HOST = "gecgithub01.walmart.com"
const ORG = "ce-orchestration"

# get all Rust repositories using gh
export def "gh repos rust" [
  # the organization to search
  --org: string = $ORG
  --host: string@get-host-label = "enterprise"
] {
  with-host $host {
    (^gh repo list
      $org
      --language Rust
      --no-archived
      --json "name,description,url,updatedAt"
    )
    | from json
  }
}

# diff two commits
# https://gecgithub01.walmart.com/ce-orchestration/router-sidecar/compare/0.4.210...0.5.2
export def "gh diff" [
  commit1: string
  commit2: string
  --repo: string
  --org: string = $ORG
  --host: string@get-host-label = "enterprise"
] {
  let host = (get-host $host)
  let url = $"https://($host)/($org)/($repo)/compare/($commit1)...($commit2)"
  print $"opening ($url)"
  ^open $url
}

def with-host [
  host: string@get-host-label
  command: closure
] {
  with-env {
    GH_HOST: (get-host $host)
  } {
    do $command
  }
}

def get-host [
  label: string@get-host-label
] {
  match $label {
    "gh" => "github.com"
    "enterprise" => $ENTERPRISE_HOST
    _ => {
      error make {
        msg: $"unknown host label: $label",
      }
    }
  }
}

def get-host-label [] {
  [gh enterprise]
}


# export def "gh pr list rust" [
#   --org: string = $ORG
# ] {
# }
