# Prometheus Alertmanager + alert rules for the homelab.
# Sends notifications to ntfy via webhook.
#
# Alertmanager receives firing alerts from Prometheus and routes them to
# receivers. Using Alertmanager instead of Grafana alerts keeps alerting
# at the Prometheus layer, which is simpler to configure declaratively.
#
# To silence or inhibit an alert: http://localhost:9093
# ntfy topic: homelab-alerts
{ config, ... }:

{
  services.prometheus.alertmanager-ntfy = {
    enable = true;
    settings = {
      ntfy = {
        baseurl = "http://localhost:8083";
        notification.topic = "homelab-alerts";
      };
    };
  };

  # Tell Prometheus where Alertmanager is running
  services.prometheus.alertmanagers = [{
    static_configs = [{
      targets = [ "localhost:${toString config.services.prometheus.alertmanager.port}" ];
    }];
  }];

  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      global.resolve_timeout = "5m";

      route = {
        receiver = "ntfy";
        group_by = [ "alertname" "instance" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      };

      receivers = [{
        name = "ntfy";
        webhook_configs = [{
          # alertmanager-ntfy translates Alertmanager JSON into readable
          # ntfy notifications (title, description, priority, emoji tags)
          url = "http://127.0.0.1:8000/hook";
          send_resolved = true;
        }];
      }];
    };
  };

  # Alert rules — evaluated by Prometheus, fired to Alertmanager
  services.prometheus.rules = [''
    groups:
      - name: homelab
        rules:

          # ── Availability ───────────────────────────────────────────────
          - alert: HostDown
            expr: up == 0
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Host {{ $labels.instance }} is down"
              description: >
                Scrape target {{ $labels.instance }} (job: {{ $labels.job }})
                has been unreachable for more than 1 minute.

          # ── CPU ────────────────────────────────────────────────────────
          - alert: HighCPU
            expr: >
              100 - (avg by(instance)
                (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "High CPU on {{ $labels.instance }}"
              description: >
                CPU usage has been above 85% for 5 minutes
                (current: {{ printf "%.1f" $value }}%).

          # ── Memory ─────────────────────────────────────────────────────
          - alert: HighMemory
            expr: >
              (1 - (node_memory_MemAvailable_bytes /
                node_memory_MemTotal_bytes)) * 100 > 90
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "High memory usage on {{ $labels.instance }}"
              description: >
                Memory usage has been above 90% for 5 minutes
                (current: {{ printf "%.1f" $value }}%).

          # ── Disk ───────────────────────────────────────────────────────
          - alert: LowDiskSpace
            expr: >
              (node_filesystem_avail_bytes{mountpoint="/",fstype!="tmpfs"} /
               node_filesystem_size_bytes{mountpoint="/",fstype!="tmpfs"})
              * 100 < 10
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "Low disk space on {{ $labels.instance }}"
              description: >
                Root filesystem has been below 10% free for 10 minutes
                (current: {{ printf "%.1f" $value }}% free).

          # ── Load ───────────────────────────────────────────────────────
          - alert: HighLoad
            expr: >
              node_load5 /
                count without(cpu, mode) (node_cpu_seconds_total{mode="idle"})
              > 2
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "High load average on {{ $labels.instance }}"
              description: >
                5-minute load average has been more than 2× CPU count for
                10 minutes (current: {{ printf "%.2f" $value }}× CPUs).
  ''];
}
