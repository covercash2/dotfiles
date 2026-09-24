# style

writing conventions for this repo — docs, comments, and any prose written in the user's voice.

## capitalization

no sentence-initial capitalization, and no capitalizing "i" — capitals are reserved for proper
nouns (`NixOS`, `Tailscale`, names, etc.). standard grammar otherwise (punctuation, sentence
structure).

CLI commands, tools, and other literal terms are always backticked, even mid-sentence — `jj`,
`ssh`, `nixos-rebuild`.

## comments and docs: code is the source of truth

code can't drift from itself. a comment or doc describing what code does can — and will,
silently, unless something checks it. so:

- **comment on what code can't show** — a non-obvious constraint, a gotcha, the reason a value
  has to be what it is. don't restate what the code already makes obvious.
- **link, don't duplicate.** a table or list that mirrors a Nix file's content (secrets, routes,
  hosts) will go stale the first time that file changes and the doc doesn't. point at the file
  instead.
- **backstory belongs in docs, not code.** if something needs a full explanation — why a bug
  happened, the reasoning behind a fix — write it once, in `docs/`. a code comment gets a fact
  and a pointer, not the story.
- **no unstable cross-module facts in a module's comments** — hostnames, hardware, "runs on
  machine X." this repo is modularized to cut interdependencies; baking another host's identity
  into a module's comment fights that.
- **this is infrastructure that runs iteratively**, not a prototype. comments shouldn't read like
  the last edit this file will ever see.

### the litmus test

before a comment or doc line survives, it has to teach something *neither of us already knows
and can't get elsewhere*. two disqualifiers:

1. **the code's own shape already implies it.** a config that correctly separates `provider` and
   `default` doesn't need prose warning that a flattened string would be wrong — the correct
   shape is self-evident, and the wrong one isn't even present to warn about.
2. **a link would answer the same question with no drift risk.** a bare doc-link comment is fine
   and wanted; a prose paraphrase of what's behind the link is not.

when in doubt, cut it shorter, not longer.
