
# a record of friendly names to key names
const VARS = {
  tavily: "TAVILY_API_KEY",
}

# Converts a .env file into a record
# may be used like this: open .env | load-env
# works with quoted and unquoted .env files
export def "from env" []: string -> record {
  lines
    | split column '#' # remove comments
    | get column1
    | parse "{key}={value}"
    | str trim value -c '"' # unquote values
    | transpose -r -d
}

export def "with var" [
  key_name: string@key_names
  value: record
] {

}

def key_names [] {
  $VARS | columns
}

def key [
  key_name: string@key_names
] {
  $VARS | get $key_name
}

