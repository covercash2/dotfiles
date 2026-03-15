# shared CA module for homelab
# uses a pre-generated CA root instead of creating one per machine
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mkcert-shared;
  certDir = "/var/lib/mkcert";
in
{
  options.services.mkcert-shared = {
    enable = lib.mkEnableOption "shared mkcert CA management";

    # path to the shared rootCA.pem file (from secrets)
    rootCACert = lib.mkOption {
      type = lib.types.path;
      description = "path to the shared root CA certificate";
    };

    # path to the shared rootCA-key.pem file (from secrets)
    rootCAKey = lib.mkOption {
      type = lib.types.path;
      description = "path to the shared root CA private key";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "domain name for this machine's certificates";
    };

    certPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/domain.pem";
      description = "path to the domain certificate";
    };

    keyPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/domain-key.pem";
      description = "path to the domain private key";
    };

    caPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${certDir}/rootCA.pem";
      description = "path to the mkcert CA certificate";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mkcert ];

    systemd.services.mkcert-shared-setup = {
      description = "deploy shared mkcert CA and generate certificates for ${cfg.domain}";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        mkdir -p ${certDir}
        chmod 755 ${certDir}

        # copy the shared CA files
        cp ${cfg.rootCACert} ${cfg.caPath}
        cp ${cfg.rootCAKey} ${certDir}/rootCA-key.pem
        chmod 644 ${cfg.caPath}
        chmod 600 ${certDir}/rootCA-key.pem

        # set CAROOT so mkcert uses our shared CA
        export CAROOT=${certDir}

        # generate certificate for this machine's domain
        cd ${certDir}
        ${pkgs.mkcert}/bin/mkcert ${cfg.domain}

        # rename the generated files
        for file in *.pem; do
          if [[ "$file" != "rootCA.pem" && "$file" != "rootCA-key.pem" ]]; then
            if [[ "$file" == *"-key.pem" ]]; then
              mv "$file" domain-key.pem
            else
              mv "$file" domain.pem
            fi
          fi
        done

        # set proper permissions
        chmod 644 ${cfg.certPath}
        chmod 600 ${cfg.keyPath}

        echo "certificates deployed successfully:"
        echo "  certificate: ${cfg.certPath}"
        echo "  private key: ${cfg.keyPath}"
        echo "  CA: ${cfg.caPath}"
      '';
    };

    # trust the shared CA system-wide
    security.pki.certificates = [
      (builtins.readFile cfg.rootCACert)
    ];
  };
}
