# Fixed mkcert certificate management
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mkcert;

  mkcertCerts = pkgs.runCommand "mkcert-certs-${builtins.replaceStrings ["."] ["-"] cfg.domain}" {
    buildInputs = [ pkgs.mkcert ];
  } ''
    set -e
    mkdir -p $out
    cd $out

    echo "Starting certificate generation for domain: ${cfg.domain}"

    # Initialize mkcert with a local CA root
    export CAROOT=$out
    mkcert -install

    echo "Generating certificate again..."
    mkcert ${lib.escapeShellArg cfg.domain}

    echo "Files created by mkcert:"
    ls -la *.pem

    # Find and rename the domain certificate and key files
    # The certificate file is any .pem file that's not the CA files
    for file in *.pem; do
      if [[ "$file" != "rootCA.pem" && "$file" != "rootCA-key.pem" ]]; then
        if [[ "$file" == *"-key.pem" ]]; then
          echo "Renaming key file: $file -> domain-key.pem"
          mv "$file" domain-key.pem
        else
          echo "Renaming certificate file: $file -> domain.pem"
          mv "$file" domain.pem
        fi
      fi
    done

    echo "Final files:"
    ls -la $out/

    # Verify required files exist
    for required in domain.pem domain-key.pem rootCA.pem; do
      if [[ ! -f "$required" ]]; then
        echo "ERROR: $required not found!"
        ls -la
        exit 1
      fi
    done

    echo "Final files:"
    ls -la $out/

    echo "Certificate generation completed successfully"
  '';

  certDir = "/var/lib/mkcert";
in
{
  options.services.mkcert = {
    enable = lib.mkEnableOption "mkcert certificate management";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "green.chrash.net";
      description = "List of domain names for the certificates (each domain can include wildcards like *.example.com)";
    };

    certPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/domain.pem";
      description = "Path to the domain certificate";
    };

    keyPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/domain-key.pem";
      description = "Path to the domain private key";
    };

    caPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/rootCA.pem";
      description = "Path to the mkcert CA certificate";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mkcert ];

    users.users.caddy = {
      group = "caddy";
      isSystemUser = true;
    };
    users.groups.caddy = {};

    systemd.services.mkcert-setup = {
      description = "Deploy mkcert certificates for ${cfg.domain}";
      wantedBy = [ "multi-user.target" ];
      before = [ "caddy.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      # create cert directory and deploy certificates
      # only if they do not already exist
      script = ''
        if [ -f "${cfg.certPath}" ] && [ -f "${cfg.keyPath}" ] && [ -f "${cfg.caPath}" ]; then
          echo "Certificates already exist at ${certDir}, skipping deployment."
          exit 0
        fi
        echo "Deploying certificates from ${mkcertCerts}..."

        mkdir -p ${certDir}
        chmod 755 ${certDir}

        # Copy certificates from Nix store
        cp ${mkcertCerts}/domain.pem ${cfg.certPath}
        cp ${mkcertCerts}/domain-key.pem ${cfg.keyPath}
        cp ${mkcertCerts}/rootCA.pem ${cfg.caPath}

        # Set proper permissions
        chmod 744 ${cfg.certPath} ${cfg.caPath}
        chmod 600 ${cfg.keyPath}
        chown caddy:caddy ${cfg.certPath} ${cfg.keyPath} ${cfg.caPath}

        echo "Certificates deployed successfully:"
        echo "  Certificate: ${cfg.certPath}"
        echo "  Private key: ${cfg.keyPath}"
        echo "  CA: ${cfg.caPath}"
      '';
    };

    security.pki.certificates = [
      (builtins.readFile "${mkcertCerts}/rootCA.pem")
    ];
  };
}
