# `mosquitto` is an MQTT broker that works well with Home Assistant.
# this module is designed to be used as an overlay for `nushell`
# and provide functionality and documentation as code for working with `mosquitto`.

# overlay state
export-env {
  $env.MOSQUITTO = {}
}

export def "mosquitto subscribe" [
  --host: string = "localhost"
  --topic: string = "#"
  --username: string = "chrash"
  --password: string
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

  print $"subscribing to topic '($topic)' on host '($host)' as user '($username)'"

  run-external ...$args
}

export def "mosquitto subscribe all" [
  --host: string = "localhost"
  --username: string = "chrash"
  --password: string
] {
  (mosquitto subscribe
    --host $host
    --topic "#"
    --username $username
    --password $password
  )
}

export def "mosquitto publish" [
  --host: string = "localhost"
  --topic: string = "test/topic"
  --message: string = "Hello, World!"
  --username: string = "chrash"
  --password: string
] {
  let password = if $password == null {
    mosquitto get password
  } else {
    mosquitto set { password: $password }
    $password
  }

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
