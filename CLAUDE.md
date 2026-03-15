# NixOS Configuration Guide

This is a flake-based NixOS + home-manager configuration for multiple hosts.
User-level config (packages, dotfiles, shell) lives in `home/` and is managed by home-manager.

## Project Structure

- `flake.nix` - Main flake configuration defining system and home-manager configurations
- `configuration.nix` - Shared base NixOS configuration for all hosts
- `home/` - home-manager modules (packages, programs, dotfiles)
- `modules/` - Modular NixOS service configurations
- `*-hardware-configuration.nix` - Hardware-specific configurations per host

### Hosts

- **green** - Main system with gaming, home automation, and web services
- **wall-e** - Secondary system
- **hoss** - System with embedded development tools

## Module Patterns

### HTTP Service Module Pattern

Services exposed via HTTPS follow this pattern:

1. Enable the service in the module
2. Register a route in `services.green.routes`
3. Configure Caddy virtual host with mkcert certificates

Example from `modules/sunshine.nix`:

```nix
{
  services.sunshine.enable = true;

  services.green.routes.sunshine = {
    url = "sunshine.${config.networking.hostName}.chrash.net";
    description = "Sunshine remote desktop route";
  };

  services.caddy.virtualHosts.${config.services.green.routes.sunshine.url} = {
    extraConfig = ''
      tls ${config.services.mkcert.certPath} ${config.services.mkcert.keyPath}
      reverse_proxy https://localhost:47990 {
        transport http {
          tls_insecure_skip_verify
        }
      }
    '';
  };
}
```

### Caddy Reverse Proxy Notes

- Always use the full cert/key path from mkcert: `${config.services.mkcert.certPath}` and `${config.services.mkcert.keyPath}`
- For HTTPS backends, use `reverse_proxy https://...` with `tls_insecure_skip_verify` in transport block
- For HTTP backends, use `reverse_proxy http://...` or just `reverse_proxy localhost:port`

## Service Architecture

### User Services vs System Services

Some NixOS services run as user services, not system services:

- **sunshine** - Runs as user service (`systemctl --user status sunshine.service`)
- Check user services with: `systemctl --user status <service>`
- Check system services with: `systemctl status <service>`

### Common Service Ports

- **sunshine**:
  - 47989 (TCP) - Base streaming port (configurable via `services.sunshine.settings.port`)
  - 47990 (TCP/HTTPS) - Web UI (always base port + 1)
  - Other ports are offsets from base: TCP offsets -5, 0, 1, 21; UDP offsets 9, 10, 11, 13, 21
- **adguard**: Custom configured port
- **homeassistant**: Custom configured port
- **foundry**: Custom configured port

## Debugging Tips

### 502 Bad Gateway Errors

When debugging 502 errors from Caddy:

1. Check if the service is running (`systemctl status` or `systemctl --user status`)
2. Check Caddy logs: `journalctl -u caddy.service -n 50`
3. Verify the port is listening: `ss -tlnp | grep <port>`
4. Check backend service logs: `journalctl -u <service> -n 50` or `journalctl --user -u <service> -n 50`
5. Test direct connection: `curl http://localhost:<port>` or `curl -k https://localhost:<port>`
6. Verify Caddy config: `cat /etc/caddy/caddy_config | grep -A 5 <hostname>`

### Common Issues

- **HTTPS backends**: Caddy needs `transport http { tls_insecure_skip_verify }` when proxying to HTTPS backends with self-signed certs
- **User services not starting**: May need manual start or enable after rebuild
- **Port mismatch**: Check if service config uses a settings attribute for port (e.g., `config.services.sunshine.settings.port` defaults to 47990)

## Rebuilding Configuration

```bash
# Rebuild for specific host (run from repo root)
sudo nixos-rebuild switch --flake /home/chrash/github/covercash2/dotfiles#green

# Test without activating
sudo nixos-rebuild test --flake /home/chrash/github/covercash2/dotfiles#green

# Build without activating
sudo nixos-rebuild build --flake /home/chrash/github/covercash2/dotfiles#green

# Switch home-manager standalone (macOS, eve)
home-manager switch --flake /home/chrash/github/covercash2/dotfiles#eve
```

## Sunshine-Specific Notes

- Runs as user service under the logged-in user
- Base streaming port: 47989 (default, configurable)
- Web UI port: Base port + 1 (47990 by default)
- Serves HTTPS on web UI port with self-signed certificate
- Requires initial setup (username/password) via web UI on first run
- Configuration stored in `~/.config/sunshine/`
- Uses `capSysAdmin = true` for DRM content playback
- Web UI shows "not authorized" until initial setup is complete
- **Important**: When configuring Caddy reverse proxy, always use `base_port + 1` for web UI access
