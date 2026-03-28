# Phone terminal session management.

use zellij.nu *

const PHONE_SESSION = "phone"

# Attach to the phone zellij session, or create it if it doesn't exist
export def "phone session" [] {
    zj open $PHONE_SESSION --layout phone
}
