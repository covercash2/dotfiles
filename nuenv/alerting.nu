# Alertmanager + ntfy utilities for testing the homelab alerting pipeline.
#
# Two test paths:
#   `alerting ntfy test`  — posts directly to ntfy (tests ntfy → phone)
#   `alerting test`       — fires a test alert through Alertmanager (tests full chain)

const NTFY_BASE_URL = "https://ntfy.green.chrash.net"
const NTFY_TOPIC = "homelab-alerts"
const ALERTMANAGER_URL = "http://localhost:9093"

# Send a test message directly to ntfy, bypassing Alertmanager.
# Use this to confirm ntfy → phone is working.
export def "alerting ntfy test" [
  --title: string = "ntfy test"                # notification title
  --message: string = "test alert from nuenv"  # message body to send
  --topic: string = $NTFY_TOPIC                # ntfy topic to post to
] {
  let url = $"($NTFY_BASE_URL)/($topic)"
  print $"posting to ($url)"
  run-external curl "-H" $"Title: ($title)" "-d" $message $url
}

# Fire a test alert through Alertmanager.
# Use this to confirm the full Prometheus → Alertmanager → ntfy → phone chain.
export def "alerting test" [
  --alertname: string = "TestAlert"            # label: alertname
  --severity: string = "warning"               # label: severity
  --instance: string = "green"                 # label: instance
  --summary: string = "Manual test alert from nuenv"  # annotation: summary
  --alertmanager: string = $ALERTMANAGER_URL   # Alertmanager base URL
] {
  let now = (date now | format date "%+")
  let payload = [{
    labels: {
      alertname: $alertname
      severity: $severity
      instance: $instance
    }
    annotations: {
      summary: $summary
    }
    startsAt: $now
  }]

  let url = $"($alertmanager)/api/v2/alerts"
  print $"firing alert '($alertname)' to ($url)"
  run-external curl "-X" "POST" "-H" "Content-Type: application/json" "-d" ($payload | to json) $url
}
