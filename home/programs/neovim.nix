# Neovim — plugins managed by vim.pack, LSP servers provided via nixpkgs.
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    # LSP servers and tools that neovim needs in its PATH.
    extraPackages = with pkgs; [
      basedpyright
      lua-language-server
      nil          # nix LSP
      vscode-langservers-extracted  # jsonls, htmlls, cssls, eslint
      ruff
      tree-sitter
      typos-lsp
      yaml-language-server
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
