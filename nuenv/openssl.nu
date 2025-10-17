# validate SSL certificates using OpenSSL
export def "ssl validate" [
  root_ca: path
  cert: path
] {

  run-external openssl verify "-CApath" $root_ca $cert
}

export def "to pem" [
  type: string@key_types
] {
  let key = $in | fold -w 64

  $"-----BEGIN ($type) KEY-----\n($key)\n-----END ($type) KEY-----"
}

def key_types [] {
  [PRIVATE PUBLIC]
}
