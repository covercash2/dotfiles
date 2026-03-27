# Phone terminal session management.
# Attach to an existing "phone" zellij session, or create one with the phone layout.

const PHONE_SESSION = "phone"

export def "phone session" [] {
    let sessions = (zellij list-sessions --no-formatting 2>/dev/null | lines | str trim | where $it == $PHONE_SESSION)
    if ($sessions | is-empty) {
        zellij --new-session-with-layout phone --session $PHONE_SESSION
    } else {
        zellij attach $PHONE_SESSION
    }
}
