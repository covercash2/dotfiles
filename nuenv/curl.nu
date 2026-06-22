# curl helpers

# clean up a "curl command" from a coworker so it runs in nushell
export def "curl clean" [
  --input: string
] {
  let input = if ($input != null) {
    $input
  } else if ($in != null) {
    $in
  } else {
    error make { msg: "No input provided to curl clean" }
  }

  let command = $input
    # remove line continuations
    | str replace --all --regex '(\\+)' ""
    # make header flags long form
    | str replace --all '-H' "--header"

  $"\(($command)\)"
}

export def "to curl" [
  --pastable # whether to generate a pastable curl command
] {
  let url = $in | get url
  let file = $in | get --optional file
  let data = $in | get --optional data
  let options = $in | get --optional options
  let headers = $in | get headers

  let curl_headers = ($headers
    | columns
    | each {|key|
        $headers | get $key
        | if $pastable { $'"($key): ($in)"' } else { $'($key): ($in)' }
        | ["--header" $in]
      })
    | flatten

  let base_args = [
    curl
    "--url" $url
  ]

  let option_args = if $options != null {
    $options
    | columns
    | each {|key|
        let value = $options | get $key
        if $value == true {
          [$"--($key)"]
        } else {
          [$"--($key)" $value]
        }
      }
    | flatten
  } else {
    []
  }

  let payload_args = if $data != null {
    let payload_str = ($data | to json | str trim)
    [
      "--header" "Content-Type: application/json"
      "--data" $'($payload_str)'
    ]
  } else {
    []
  }

  let file_args = if $file != null {
    [
      "--form" $"file1=@($file)"
    ]
  } else {
    []
  }

  let args = ($base_args
    ++ $curl_headers
    ++ $option_args
    ++ $payload_args
    ++ $file_args
  )

  print $"curl args: ($args)"

  $args
}

export def nucurl [
  --headers: record
  --data: record
  --options: record # curl options
  --pastable
  url: string
] {
  let args = {
    url: $url
    headers: $headers
    data: $data
    options: $options
  } | to curl --pastable=$pastable

  print ($args | str join " ")

  run-external $args
}

def http_methods [] {
  [GET POST PATCH PUT DELETE HEAD OPTIONS]
}
