# certificates

internal HTTPS for `*.green.chrash.net` uses a shared private CA managed via
[mkcert] and [sops-nix]. all NixOS hosts trust the CA automatically. non-NixOS
devices (phone, work Mac) install it once via the `/ca` endpoint on Tailscale.

## how it works

- a single CA key+cert is generated once and stored in `secrets/green.yaml` (key)
  and `certs/ca.pem` (cert, committed to the repo — it's public).
- on `green`, `modules/shared-ca.nix` decrypts the CA key from sops, then uses
  `mkcert` (with `CAROOT` pointing at the decrypted files) to generate a wildcard
  cert for `*.green.chrash.net`. Caddy uses these certs for all virtual hosts.
- on `wall-e` and `hoss`, `security.pki.certificates` bakes the CA cert into the
  system trust store at build time — no manual steps needed after `nixos-rebuild`.
- on the phone (or any non-NixOS device), visit
  `https://green.faun-truck.ts.net/ca` over Tailscale and install the cert.
  Tailscale provides a real HTTPS cert for `*.ts.net`, so this download is trusted.

## first-time CA setup

run these on `green` to generate the shared CA. do this once — the CA key must
never be regenerated or all devices will need to re-trust it.

```nu
# 1. find where mkcert keeps its CA (or run `mkcert -install` to generate one)
let caroot = (mkcert -CAROOT | str trim)

# 2. commit the CA cert to the repo
cp $"($caroot)/rootCA.pem" ~/github/covercash2/dotfiles/certs/ca.pem
# git add certs/ca.pem && git commit

# 3. add the CA key to sops — use --file to preserve newlines in the PEM
overlay use ~/github/covercash2/dotfiles/nuenv/sops.nu
secrets add ca_key --file $"($caroot)/rootCA-key.pem"
```

## rebuilding after CA setup

```bash
just switch   # on green — generates domain cert from shared CA, restarts caddy
just switch   # on wall-e / hoss — bakes CA cert into system trust store
```

## installing the CA on non-NixOS devices

on any device connected to the Tailnet:

```
https://green.faun-truck.ts.net/ca
```

download the cert and install it as a trusted CA:

- **Android/iOS (ntfy, browser):** Settings → Security → Install certificate → CA certificate
- **macOS:** double-click the cert → Keychain Access → trust for SSL
- **manual `curl`:** `curl -k https://green.faun-truck.ts.net/ca -o ca.pem && sudo trust anchor ca.pem`

## rotating the CA

rotation requires re-installing the CA on every device. avoid unless the key is
compromised.

1. delete `/var/lib/mkcert/` on green.
2. follow the [first-time CA setup](#first-time-ca-setup) steps above.
3. update `secrets/green.yaml` with the new `ca_key`.
4. replace `certs/ca.pem` in the repo with the new cert and commit.
5. rebuild all hosts and re-install the CA on non-NixOS devices.

## troubleshooting

**`permission denied` on `domain-key.pem` — caddy fails to start**

the `mkcert-shared-setup` service didn't chown the key to caddy. fix the live
files without a full rebuild:

```bash
sudo chown caddy:caddy /var/lib/mkcert/domain.pem /var/lib/mkcert/domain-key.pem
sudo systemctl start caddy
```

**caddy starts but clients still get SSL errors after a rebuild**

Caddy may be serving a stale cert it loaded before `mkcert-shared-setup` ran.
check whether the fingerprint caddy is serving matches the cert on disk:

```bash
# cert caddy is serving
bash -c "echo | openssl s_client -connect 127.0.0.1:443 -servername ntfy.green.chrash.net 2>/dev/null | openssl x509 -noout -fingerprint"

# cert on disk
openssl x509 -noout -fingerprint -in /var/lib/mkcert/domain.pem
```

if they differ, restart caddy: `sudo systemctl restart caddy`

**`secrets add ca_key` stored the key without newlines**

the interactive `secrets add` prompt reads a single line. always use `--file`
for PEM keys — see step 3 of the setup above.

[mkcert]: https://github.com/FiloSottile/mkcert
[sops-nix]: https://github.com/Mic92/sops-nix
