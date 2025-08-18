# validate SSL certificates using OpenSSL
export def "ssl validate" [
  root_ca: path
  cert: path
] {

  run-external openssl verify "-CApath" $root_ca $cert
}

export def "to sr_properties" [] {
  let lines = $in | lines | sort
  let version_line = $lines | get 0 | parse "keyVersion.{consumer_id}={version}" | first
  let key_line = $lines | get 1 | parse "privateKey.{consumer_id}={private_key}" | first

  # ensure consumer IDs match
  if $key_line.consumer_id != $version_line.consumer_id {
    error make {
      msg: "Consumer IDs do not match: keyLine.consumer_id=$key_line.consumer_id, versionLine.consumer_id=$version_line.consumer_id"
    }
  }

  {
    consumer_id: $key_line.consumer_id
    private_key: $key_line.private_key
    version: $version_line.version
  }
}

export def "sr properties to pem" [
  signature_properties: path
  --base64
] {
  let input = if $base64 {
    cat $signature_properties | base64 --decode
  } else {
    cat $signature_properties
  }

  let input = $input | to sr_properties

  let consumer_id = $input.consumer_id
  let private_key = $input.private_key
  let version = $input.version

  print $"key for ($consumer_id) with version ($version)\n"

  let private_key = $private_key | fold -w 64

  $"-----BEGIN PRIVATE KEY-----\n($private_key)\n-----END PRIVATE KEY-----"
}
