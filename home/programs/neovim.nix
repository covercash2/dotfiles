# Neovim — config linked from repo, LSPs managed via Mason except for
# the few that are cleanly packaged in nixpkgs.
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    # Tools that neovim needs in its PATH. Mason manages everything else.
    extraPackages = with pkgs; [
      lua-language-server
      nil          # nix LSP
      typos-lsp
      black        # Python formatter
      djhtml       # Django/Jinja template formatter
    ];
  };

  # recursive = true creates ~/.config/nvim/ as a real (writable) directory
  # with symlinks to individual files. vim.pack needs this to write its
  # lockfile (nvim-pack-lock.json) into the config directory.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
