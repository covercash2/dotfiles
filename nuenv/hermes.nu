# Helpers for the hermes-agent service (modules/hermes.nix).
#
# state dir is chmod 2770 hermes:hermes, so reading config/sessions or
# running the `hermes` CLI needs `sudo -u hermes`; restarting the unit needs
# root.
#
# usage:
#   overlay use nuenv/hermes.nu
#   hermes-agent status              # doctor report, as the service sees it
#   hermes-agent ping                # one-shot "say pong" smoke test
#   hermes-agent ask "some prompt"   # one-shot prompt, chat-only (no tools)
#   hermes-agent ask --tools "..."   # one-shot prompt, tools enabled
#   hermes-agent config              # print the merged config.yaml
#   hermes-agent logs                # follow the journal
#   hermes-agent restart             # restart the unit and tail startup logs

# run a hermes CLI subcommand as the hermes user, with its real $HOME.
# `--wrapped` passes args straight through instead of parsing them as flags
# on this def, so `-t none -z "..."` reaches the real `hermes` untouched.
def --wrapped run-as-hermes [...args] {
  run-external sudo "-u" hermes "-H" hermes ...$args
}

# doctor report — dependency/config health as the running service sees it
export def "hermes-agent status" [] {
  run-as-hermes doctor
}

# one-shot smoke test: no tools, just confirm the model answers
export def "hermes-agent ping" [] {
  run-as-hermes -t none -z "Reply with exactly one word: pong"
}

# one-shot prompt. --tools enables the default toolset (terminal, etc.)
export def "hermes-agent ask" [
  prompt: string
  --tools  # allow tool calls instead of chat-only
] {
  if $tools {
    run-as-hermes -z $prompt
  } else {
    run-as-hermes -t none -z $prompt
  }
}

# the merged config.yaml Nix + hermes-config-merge produced on disk
export def "hermes-agent config" [] {
  run-external sudo cat /var/lib/hermes/.hermes/config.yaml | from yaml
}

# follow the service journal
export def "hermes-agent logs" [
  --lines (-n): int = 50  # backlog to show before following
] {
  run-external sudo journalctl "-u" hermes-agent "-n" ($lines | into string) "-f"
}

# restart the unit and tail the startup log — nixos-rebuild won't restart it
# on its own for a config-only change
export def "hermes-agent restart" [] {
  run-external sudo systemctl restart hermes-agent
  run-external sudo journalctl "-u" hermes-agent "-n" "0" "-f"
}
