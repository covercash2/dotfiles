# certificates

Internal HTTPS for `*.green.chrash.net` uses a shared private CA managed via
[mkcert] and [sops-nix]. All NixOS hosts trust the CA automatically. Non-NixOS
devices (phone, work Mac) install it once via the `/ca` endpoint on Tailscale.

## how it works

- A single CA key+cert is generated once and stored in `secrets/green.yaml` (key)
  and `certs/ca.pem` (cert, committed to the repo — it's public).
- On `green`, `modules/shared-ca.nix` decrypts the CA key from sops, then uses
  `mkcert` (with `CAROOT` pointing at the decrypted files) to generate a wildcard
  cert for `*.green.chrash.net`. Caddy uses these certs for all virtual hosts.
- On `wall-e` and `hoss`, `security.pki.certificates` bakes the CA cert into the
  system trust store at build time — no manual steps needed after `nixos-rebuild`.
- On the phone (or any non-NixOS device), visit
  `https://green.faun-truck.ts.net/ca` over Tailscale and install the cert.
  Tailscale provides a real HTTPS cert for `*.ts.net`, so this download is trusted.

## first-time CA setup

Run these on `green` to generate the shared CA. Do this once — the CA key must
never be regenerated or all devices will need to re-trust it.

```nu
# 1. generate the CA
cd /tmp
mkdir shared-ca
cd shared-ca
CAROOT=$PWD mkcert -install
# produces: rootCA.pem (cert) and rootCA-key.pem (key)

# 2. commit the CA cert to the repo
cp rootCA.pem /path/to/dotfiles/certs/ca.pem
# git add certs/ca.pem && git commit

# 3. add the CA key to sops
overlay use /path/to/dotfiles/nuenv/sops.nu
secrets add ca_key   # paste the contents of rootCA-key.pem when prompted

# 4. clean up — do not leave the key on disk
rm -rf /tmp/shared-ca
```

## rebuilding after CA setup

```bash
just switch   # on green — generates domain cert from shared CA, restarts caddy
just switch   # on wall-e / hoss — bakes CA cert into system trust store
```

## installing the CA on non-NixOS devices

On any device connected to the Tailnet:

```
https://green.faun-truck.ts.net/ca
```

Download the cert and install it as a trusted CA:

- **Android/iOS (ntfy, browser):** Settings → Security → Install certificate → CA certificate
- **macOS:** double-click the cert → Keychain Access → trust for SSL
- **manual curl:** `curl -k https://green.faun-truck.ts.net/ca -o ca.pem && sudo trust anchor ca.pem`

## rotating the CA

Rotation requires re-installing the CA on every device. Avoid unless the key is
compromised.

1. Delete `/var/lib/mkcert/` on green.
2. Follow the [first-time CA setup](#first-time-ca-setup) steps above.
3. Update `secrets/green.yaml` with the new `ca_key`.
4. Replace `certs/ca.pem` in the repo with the new cert and commit.
5. Rebuild all hosts and re-install the CA on non-NixOS devices.

[mkcert]: https://github.com/FiloSottile/mkcert
[sops-nix]: https://github.com/Mic92/sops-nix
