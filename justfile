# every machine on the network runs nushell — recipes are nu, not sh/bash.
set shell := ["nu", "-c"]

hostname := shell('hostname')

# list recipes
default:
  just --list

# run home-manager for standalone hosts (macOS, VPS)
# uses `nix run` so it works even before home-manager is in PATH
home:
  nix run github:nix-community/home-manager -- switch --flake .#eve --print-build-logs

home-foundry:
  home-manager switch --flake .#foundry

# install NixOS on foundry via nixos-anywhere (destructive — wipes the disk)
deploy-foundry:
  nix run github:nix-community/nixos-anywhere -- --flake .#foundry chrash@foundry

# build the foundry config on hoss and deploy it to foundry over ssh
# --ask-elevate-password prompts *locally* (no remote tty needed) and feeds
# the password to `sudo --stdin` on the target host.
switch-foundry:
  nixos-rebuild switch --flake .#foundry --build-host chrash@hoss --target-host chrash@foundry --ask-elevate-password --print-build-logs

# build the green config on hoss and deploy it to green over ssh
switch-green:
  nixos-rebuild switch --flake .#green --build-host chrash@hoss --target-host chrash@green --ask-elevate-password --print-build-logs

# build the system configuration without switching
build: check
  nixos-rebuild build --flake .#{{hostname}} --print-build-logs

# build and switch to the new system configuration
switch: build
  sudo nixos-rebuild switch --flake .#{{hostname}} --print-build-logs

# switch without printing build logs
switch_quiet:
  sudo nixos-rebuild switch --flake .#{{hostname}}

# If sops-install-secrets fails during activation (e.g. a secret is owned by a
# user that doesn't exist yet), it aborts *all* secret setup, so /run/secrets/
# is never created. on hoss that removes /run/secrets/nix_signing_key, which
# nix.settings.secret-key-files points at — and nix then refuses every build
# ("opening file /run/secrets/nix_signing_key: No such file or directory"),
# including the rebuild that would fix the config. a bootstrap deadlock.
#
# `--option secret-key-files ''` breaks it: build this once without signing so
# activation can run and repopulate /run/secrets/. the resulting paths are
# unsigned, which only matters if another host substitutes them directly from
# here before the next normal `just switch` re-signs them — harmless in
# practice. do NOT fold this flag into `switch`; build signing is load-bearing
# for hoss as a remote builder (modules/hoss-builder.nix), and a silent bypass
# would hide the next sops breakage instead of failing loudly.

# recover from a broken sops-nix activation — see docs/troubleshooting.md
rescue-switch:
  sudo nixos-rebuild switch --flake .#{{hostname}} --option secret-key-files '' --print-build-logs

build_rescue:
  nix build .#nixosConfigurations.rescue-disk.config.system.build.isoImage

# test the configuration without applying it
dry_build:
  nixos-rebuild dry-activate --sudo --flake .#{{hostname}} #--upgrade

# run every repo-wide check: nix eval, typo scan, python lint, nu test suite, hermes plugins
check: check_nix check_typos check_ruff check_nu check_hermes_plugins

# evaluate every flake output (NixOS + home-manager configs) without building
check_nix:
  nix flake check --no-build

# catch typos across the repo (see typos.toml for accepted domain words)
check_typos:
  typos

# lint the repo's Python (hermes-plugins/, scripts/) — ruff, via home/packages.nix
check_ruff:
  ruff check hermes-plugins scripts

# run the nuenv test suite (nuenv/testing.nu). A fresh `nu -c` subprocess so
# its startup CWD is already nuenv/ — `overlay use` resolves at parse time,
# before a same-script `cd` has run, and test fixtures (e.g. zigbee.nu's)
# resolve their own paths against CWD too.
check_nu:
  cd nuenv; nu -c 'overlay use testing.nu; run-tests --path .'

# validate every Hermes plugin (hermes-plugins/<name>/) against the real
# runtime contracts: manifest parsing, import, register(ctx), tool/hook
# registration. See hermes-plugins/ (not modules/ — not Nix-specific).
check_hermes_plugins:
  for d in (ls hermes-plugins | where type == dir | get name) { hermes plugins doctor $d --ci; if $env.LAST_EXIT_CODE != 0 { exit $env.LAST_EXIT_CODE } }

update_flake:
  nix flake update --flake .

# update NixOS channels https://nixos.wiki/wiki/Nix_channels
update_channels:
  sudo nix-channel --update

# invoke the garbage collector
# https://nixos.org/guides/nix-pills/11-garbage-collector.html
gc:
  nix-collect-garbage

# full system update
update_system: update_channels update_flake switch
