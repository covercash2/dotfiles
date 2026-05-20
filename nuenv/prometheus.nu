const PROMETHEUS_URL = "http://localhost:9090"

def xh-get [url: string, ...params: string] {
  run-external xh "--body" GET $url ...$params | from json
}

# Run an instant PromQL query. Returns a table of metric labels + value.
export def "prom query" [
  expr: string                        # PromQL expression
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
  --time: string                      # evaluation timestamp (RFC3339 or Unix)
  --raw                               # return raw API response instead of formatted table
] {
  mut params = [$"query==($expr)"]
  if $time != null { $params = ($params | append $"time==($time)") }

  let resp = xh-get $"($url)/api/v1/query" ...$params

  if $raw { return $resp }

  $resp
  | get data.result
  | each {|r| $r.metric | insert value ($r.value | get 1) }
}

# Run a range PromQL query. Returns the raw result list (matrix).
export def "prom query range" [
  expr: string                        # PromQL expression
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
  --start: string                     # start time (RFC3339 or Unix), default 1h ago
  --end: string                       # end time (RFC3339 or Unix), default now
  --step: string = "1m"               # resolution step (e.g. 30s, 5m, 1h)
  --raw                               # return raw API response
] {
  let t_end   = (date now | format date "%+")
  let t_start = ((date now) - 1hr | format date "%+")

  let params = [
    $"query==($expr)"
    $"start==(if $start != null { $start } else { $t_start })"
    $"end==(if $end != null { $end } else { $t_end })"
    $"step==($step)"
  ]

  let resp = xh-get $"($url)/api/v1/query_range" ...$params

  if $raw { return $resp }

  $resp | get data.result
}

# List all metric names known to Prometheus.
export def "prom metrics" [
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
] {
  xh-get $"($url)/api/v1/label/__name__/values" | get data
}

# List all label names known to Prometheus.
export def "prom labels" [
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
] {
  xh-get $"($url)/api/v1/labels" | get data
}

# List all values for a label.
export def "prom label values" [
  label: string                       # label name (e.g. job, instance)
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
] {
  xh-get $"($url)/api/v1/label/($label)/values" | get data
}

# Find time series matching a selector.
export def "prom series" [
  match: string                       # series selector (e.g. '{job="homeassistant"}')
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
] {
  xh-get $"($url)/api/v1/series" $"match[]==($match)" | get data
}

# Show active scrape targets and their health status.
export def "prom targets" [
  --url: string = $PROMETHEUS_URL     # Prometheus base URL
] {
  xh-get $"($url)/api/v1/targets"
  | get data.activeTargets
  | select scrapePool lastScrape health lastError
}
