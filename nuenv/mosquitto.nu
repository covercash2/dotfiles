# `mosquitto` is an MQTT broker that works well with Home Assistant.
# this module is designed to be used as an overlay for `nushell`
# and provide functionality and documentation as code for working with `mosquitto`.

# overlay state
export-env {
  $env.MOSQUITTO = {}
}

# subscribe to a topic
# https://mosquitto.org/man/mosquitto_sub-1.html
export def "mosquitto subscribe" [
  --host: string = "localhost"
  --format: string@"mosquitto formats" = payload-only
  --username: string = "chrash"
  --password: string
  topic: string
] {
  let password = if $password == null {
    mosquitto get password
  } else {
    mosquitto set { password: $password }
    $password
  }

  let args = [
    mosquitto_sub
    -h $host
    -t $topic
    -u $username
    -P $password
  ]

  let args = if $format != null {
    let format = mosquitto formats resolve $format
    print $"using format '($format)'"
    $args ++ ["-F" $format]
  } else {
    $args
  }

  print $"subscribing to topic '($topic)' on host '($host)' as user '($username)'"

  run-external ...$args
}

# subscribe to all topics
export def "mosquitto subscribe all" [
  --host: string = "localhost"
  --format: string@"mosquitto formats" = payload-only # payload only is the default format
  --username: string = "chrash"
  --password: string
] {
  (mosquitto subscribe
    --host $host
    --format $format
    --username $username
    --password $password
    "#"
  )
}

export const FORMAT_JSON_FULL: record = {
  topic: "%t",
  payload: "%p",
  content-type: "%C",
  message-expiry-interval: "%E",
  length: "%l",
  id: "%m",
  user-property: "%P",
  qos: "%q",
  response-topic: "%R",
  retain: "%r",
  subscription-identifier: "%S",
}

# publish a message to a topic
# https://mosquitto.org/man/mosquitto_pub-1.html
export def "mosquitto publish" [
  --host: string = "localhost"
  --topic: string = "test/topic"
  --message: record = { message: "Hello, World!" }
  --username: string = "chrash"
  --password: string
] {
  let password = if $password == null {
    mosquitto get password
  } else {
    mosquitto set { password: $password }
    $password
  }

  let message = if ($message | is-empty) { "" } else { $message | to json }

  let args = [
    mosquitto_pub
    "-h" $host
    "-t" $topic
    "-m" $message
    "-u" $username
    "-P" $password
  ]
  run-external ...$args
}

export def --env "mosquitto set" [
  options: record
] {
  $env.MOSQUITTO = ($env.MOSQUITTO | merge $options)
}

export def "mosquitto get" [
  key: string
  --optional
] {
  if $optional {
    $env.MOSQUITTO | get --optional $key
  } else {
    try {
      $env.MOSQUITTO | get $key
    } catch {
      error make {
        msg: $"key '($key)' not set; please set it using `mosquitto set { ($key): <value> }`"
      }
    }
  }
}

def "mosquitto formats" [] {
  [json-full payload-only]
}

def "mosquitto formats resolve" [
  format: string@"mosquitto formats"
] {
  match $format {
    "json-full" => "%J",
    "payload-only" => "%p",
    _ => (error make { msg: $"unknown format '($format)'" })
  }
}
