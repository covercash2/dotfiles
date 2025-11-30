# some postgres commands for docs-as-code
# otherwise just use pgcli

const DB_URL = "postgresql://chrash:5432/chrash"

# root command for postgres interactions
export def pg [] {
  print "root command for postgres interactions"
}

# run a psql command with the given arguments
export def "pg run" [
  command: string
] {
  let args = [
    psql
    $"--command=($command)"
  ]

  print ($args | str join " ")

  run-external ...$args
}

# list all databases
export def "pg db list" [] {
  pg run '\l'
}

# list all tables in a database
export def "pg table list" [
  database: string
] {
  pg run $'\c ($database) \dt'
}
