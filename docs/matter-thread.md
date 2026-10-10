# matter / thread

green runs an OpenThread Border Router (`otbr`) and `matter-server` as plain
containers — see [`modules/thread.nix`](../modules/thread.nix) for the setup
and why it's not Home Assistant's official add-ons (those need Supervisor;
green runs HA as a plain container, see
[`modules/homeassistant.nix`](../modules/homeassistant.nix)). `otbr` bridges
the SLZB-MR1U's second radio — see
[`modules/zigbee_receiver.nix`](../modules/zigbee_receiver.nix) for the first
radio, which still does Zigbee.

## onboarding a new device

1. put the device in pairing mode. this is device-specific — e.g. GE Cync
   bulbs: power-cycle 5 times quickly (off 2s, on 2s, × 5) until it blinks.
2. in the HA app: Settings → Devices & Services → Add Device → Matter →
   scan the QR code or enter the 11-digit code.
3. **check whether the device is Wi-Fi or Thread before troubleshooting
   anything** — the box/QR usually says. the two failure modes below look
   identical ("it just fails") but have nothing in common.

## Wi-Fi devices: phone must be on the same band it's commissioning to

most Matter-over-Wi-Fi devices (bulbs especially) only have 2.4GHz radios.
if the network you're provisioning the device onto is a dedicated 2.4GHz
SSID (e.g. `wirt 2.4`, split from the main `wirt` network), **the phone
doing the commissioning has to be joined to that same SSID at the time of
pairing** — not just "on the same Wi-Fi," the same band.

if the phone is on the 5GHz network while the device is being handed
`wirt 2.4` credentials over BLE, it fails with "Unable to Connect to
Network" on the phone, with **zero trace in any server log** — not
`otbr`, not `matter-server`, not Caddy, not Home Assistant itself. the
whole BLE exchange and the device's network-join attempt happen before
anything reaches green at all, so there is nothing to debug server-side.
this is the thing to check first, not last — see the debugging checklist
below.

**fix:** switch the phone to the 2.4GHz SSID before starting onboarding.
switch back afterward if you want.

## Thread devices: known gaps in this (non-Supervisor) setup

- **two separate Thread networks exist on the LAN** if you already have an
  Apple Home Thread mesh (HomePods/Apple TVs acting as border routers):
  green's own (`otbr`-formed) network, and the existing Apple one. a Thread
  device can only join one. Apple's native Matter commissioner — not
  `matter-server`, which has no Bluetooth of its own
  (`curl localhost:5580/info` → `bluetooth_enabled: false`) — decides which
  network to hand the device, from whatever Thread credentials iOS already
  has. marking a network "preferred" in HA's own Thread panel does **not**
  control this choice; that's purely a client-side iOS decision. a Thread
  device commissioned onto a network green's `otbr` doesn't participate in
  is invisible to Home Assistant no matter what else is configured
  correctly.
- **HA doesn't reliably push the active Thread dataset into
  `matter-server` on its own** in this setup. confirmed by watching
  `curl localhost:5580/info`'s `thread_credentials_set` field stay `false`
  through marking a network preferred, reloading the Matter integration,
  and restarting `matter-server` outright — none of it triggered a push.
  workaround, if this bites again: pull the active dataset's TLV from
  `otbr` and push it directly via `matter-server`'s own websocket API
  (`otbr`'s REST API has no auth; `matter-server`'s websocket command is
  `set_thread_dataset`, documented in
  [python-matter-server](https://github.com/home-assistant-libs/python-matter-server)):
  ```
  curl -H "Accept: text/plain" http://localhost:8081/node/dataset/active
  # feed the resulting hex TLV as {"message_id":"1","command":"set_thread_dataset","args":{"dataset":"<tlv>"}}
  # to ws://localhost:5580/ws
  ```
  this isn't wired into the Nix config as an automated fix yet — it was a
  one-off manual push, not a persisted/declarative fix. if Thread
  onboarding becomes routine, this should become a oneshot systemd service
  (same pattern as `green-vault-sync` in
  [`modules/green.nix`](../modules/green.nix)) rather than a manual step.

## debugging checklist

**check for any server-side trace first — complete silence tells you to
stop looking at the server entirely:**

```nu
journalctl -u podman-otbr.service -f
journalctl -u podman-matter-server.service -f
journalctl -u caddy.service -f
```

if none of these show anything during an onboarding attempt, the failure
is happening entirely client-side (BLE pairing or the device's own
network-join attempt) — go check the phone's Wi-Fi band or the device's
physical range from a Thread border router, not Nix config or container
logs.

if there *is* server-side activity, check component health directly:

```nu
curl http://localhost:5580/info     # matter-server: wifi/thread credential state
curl http://localhost:8081/node/state       # otbr: disabled/detached/leader/etc.
curl http://localhost:8081/node/dataset/active   # otbr: the network's dataset, JSON form
```
