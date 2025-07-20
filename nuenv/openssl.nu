# validate SSL certificates using OpenSSL
export def "ssl validate" [
  root_ca: path
  cert: path
] {

  run-external openssl verify "-CApath" $root_ca $cert
}
