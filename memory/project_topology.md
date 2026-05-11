---
name: Network topology
description: Machine inventory, IPs, roles, and services across the homelab
type: reference
---

Full topology is documented at `docs/topology.md` in the dotfiles repo. Key facts:

- **eve**: personal MacBook (primary workstation), standalone home-manager
- **boxer**: work MacBook (Walmart, username `c0o02bc`), standalone home-manager
- **green** `192.168.2.216`: homelab server, 16GB RAM, GTX 1060. Runs all self-hosted services (AdGuard, Home Assistant, Frigate, Jellyfin, Grafana, Prometheus, Caddy, Postgres, Miniflux, ntfy, Ultron, FoundryVTT, Z-Wave, Zigbee). Has JetKVM for out-of-band access.
- **hoss** `192.168.2.136`: workstation/build machine, 64GB RAM, RTX 4090. Runs Ollama (CUDA), Sunshine game streaming. Trusted Nix remote builder. WoL enabled. No out-of-band management.
- **wall-e**: desktop NixOS machine, Nvidia GPU.
- **foundry**: Digital Ocean VPS, ingress + AdGuard DNS replica. Rebuilds from GitHub.
- **rescue-disk**: bootable recovery ISO.

Network: `192.168.2.0/24`, gateway `192.168.2.1`. All machines on Tailscale.
Internal TLS via shared homelab CA (`certs/ca.pem`), distributed to all machines.
DNS: AdGuard on green (primary) + foundry (replica), synced via adguardhome-sync.
