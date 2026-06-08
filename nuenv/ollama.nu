# developed from https://github.com/covercash2/djinn
# const OLLAMA_HOST = "https://ollama.hoss.chrash.net"

export-env {
  load-env {
    OLLAMA_HOST: "https://ollama.hoss.chrash.net"
  }
}

# a helper for any GET commands
export def "ollama get" [
  endpoint: string
] {
  let host = $env | get OLLAMA_HOST
  xh get $"($host)/api/($endpoint)"
}

# a helper for any POST commands
export def "ollama post" [
  endpoint: string
  payload: record
] {
  let host = $env | get OLLAMA_HOST

  let payload = $payload | to json

  xh post --json $"($host)/api/($endpoint)" --raw $payload
}

# list available models (using the /api/tags endpoint)
export def "ollama list" [] {
  ollama get tags
}

export def "ollama modelinfo" [
  name: string
] {
  ollama post show { name: $name }
}

export def "ollama download modelinfo" [
  names: list
  output_dir: path
] {
  $names | each { |name|
      print $name
      ollama post show { name: $name }
      | save --force ($output_dir | path join $"($name).model.json")
    }
}

export def "ollama download modelinfo all" [
  output_dir: path
] {
  let names = ollama list
    | get models.name
  ollama download modelfiles $names $output_dir
}

export def "ollama download modelfile all" [
  output_dir: path
] {
  ollama list
  | get models.name
  | each {|name|
    ollama post show { name: $name }
    | get modelfile
    | save --force ($output_dir | path join $"($name).Modelfile")
  }
}

export def "ollama pull" [
  name: string
] {
  ollama post pull { model: $name stream: false }
}

# create a model from existing sources
# https://github.com/ollama/ollama/blob/main/docs/api.md#parameters-2
export def "ollama create" [
  model: string # the name of the model to create
  --from: string  # the name of the model to copy
  --system: string # the default system messages
  --adapters: record # file names to SHA256 digests of blobs for LoRA adapters
  --template: string # the prompt template (a go template)
  --parameters: record # a dictionary of parameters for the model
  --messages: list # a list of messages objects used to create a conversation
  --license: string
  --quantize: string@quantizations # attempt to quantize the model
  --no-stream # don't stream the response
] {
  let payload = {
    model: $model
    from: $from
    stream: (not $no_stream)
  }

  let payload = if $adapters == null { $payload } else { $payload | insert adapters $adapters }
  let payload = if $template == null { $payload } else { $payload | insert template $template }
  let payload = if $license == null { $payload } else { $payload | insert license $license }
  let payload = if $system == null { $payload } else { $payload | insert system $system }
  let payload = if $parameters == null { $payload } else { $payload | insert parameters $parameters }
  let payload = if $messages == null { $payload } else { $payload | insert messages $messages }
  let payload = if $quantize == null { $payload } else { $payload | insert quantize $quantize }

  print creating model $payload ($payload | to json)

  ollama post create $payload
}

# quantizations
# the documentation recommends q8_0 or q4_K_M
def quantizations [] {
  [
    q8_0
    q4_K_M
    q2_K
    q3_K_L
    q3_K_M
    q3_K_S
    q4_0
    q4_1
    q4_K_S
    q5_0
    q5_1
    q5_K_M
    q5_K_S
    q6_K
  ]
}
