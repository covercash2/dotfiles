# explore a JSON file using neovim and jq
export def "json explore" [
	file: path # a JSON file to open
]: [] {
	let args = $'+"JqPlayground ($file)"'
	run-external nvim $args
}

export def "json fmt" [
  file: path # a JSON file to format
  --interactive
] {
  let input = open --raw $file
  let output = $input | from json | to json

  let d = $input | str distance $output

  print $"(ansi yellow_bold)($d) changes(ansi reset)"

  if $interactive {
    (
      [yup nope]
      | input list
        $"save (ansi white_italic)($file)(ansi reset)?"
    )
  } else {
    $output | save --force $file
  }
}
