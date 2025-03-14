# dotfiles and configs

this repo is for storing my config files.

[`chezmoi`](https://github.com/twpayne/chezmoi) is used to manage the copying and linking of dotfiles.

# `chezmoi`

with `chezmoi` installed:

``` sh
# initialize
$ chezmoi init https://github.com/covercash2/dotfiles.git
# apply
$ chezmoi apply
# both at once
$ chezmoi init --apply --verbose https://github.com/covercash2/dotfiles.git
# update
$ chezmoi update

```

# `root_etc`

these files are not copied directly by chezmoi, since it only works with user privileges.

- `sshd_config`: basically just configure pubkey auth only
- `xorg.conf/30-ds4.conf`: disable DualShock 4 touchpad

# `nuenv`

this is just a set of conventions that i use
to provide wrappers and convenience functions.
the `nuenv` directory is added to the `NU_LIBS_DIR`,
which allows me to summon `nushell` overlays easily:

```nu
overlay use git.nu


```

