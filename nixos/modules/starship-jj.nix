{ config, pkgs, ... }:

let
  starship-jj = pkgs.rustPlatform.buildRustPackage rec {
    pname = "starship-jj";
    version = "0.6.0";

    src = pkgs.fetchFromGitLab {
      owner = "lanastara_foss";
      repo = "starship-jj";
      rev = version;
      sha256 = "sha256-HTkDZQJnlbv2LlBybpBTNh1Y3/M8RNeQuiked3JaLgI=";
    };

    cargoHash = "sha256-E5z3AZhD3kiP6ojthcPne0f29SbY0eV4EYTFewA+jNc=";

    meta = with pkgs.lib; {
      description = "Starshiup prompt plugin for jj version control";
      homepage = "https://gitlab.com/lanastara-foss/starship-jj";
      license = licenses.mit;
      maintainers = [ lanastara ];
    };
  };
in
{
  environment.systemPackages = [ starship-jj ];
}
