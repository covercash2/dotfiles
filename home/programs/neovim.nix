# Neovim — config linked from repo, LSPs managed via Mason except for
# the few that are cleanly packaged in nixpkgs.
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # Tools that neovim needs in its PATH. Mason manages everything else.
    extraPackages = with pkgs; [
      lua-language-server
      nil          # nix LSP
      typos-lsp
      black        # Python formatter
      djhtml       # Django/Jinja template formatter
    ];
  };

  xdg.configFile."nvim".source = ./nvim;
}
