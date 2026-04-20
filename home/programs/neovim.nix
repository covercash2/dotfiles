# Neovim — plugins managed by vim.pack, LSP servers provided via nixpkgs.
{ pkgs, hostname, ... }:

let
  # mcp-hub has no nixpkgs derivation; wrap npx to get it on PATH.
  mcp-hub = pkgs.writeShellScriptBin "mcp-hub" ''
    exec ${pkgs.nodejs}/bin/npx mcp-hub "$@"
  '';

  isBoxer = hostname == "m-ry6wtc3pxk";
in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    # LSP servers and tools that neovim needs in its PATH.
    extraPackages = with pkgs; [
      lua-language-server
      nil          # nix LSP
      typos-lsp
      yaml-language-server
      black        # Python formatter
      djhtml       # Django/Jinja template formatter
    ] ++ pkgs.lib.optionals isBoxer [
      mcp-hub
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
