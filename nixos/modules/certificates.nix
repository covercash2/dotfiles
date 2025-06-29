# mkcert certificate management module
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mkcert;
  userConfig = config.users.users.${cfg.user};
  userHome = userConfig.home;
in
{
  options.services.mkcert = {
    enable = lib.mkEnableOption "mkcert certificate management";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "green.chrash.net";
      description = "Domain name for the certificate";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "chrash";
      description = "User who owns the mkcert certificates";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install mkcert
    environment.systemPackages = with pkgs; [ mkcert ];

    # Create systemd service to manage certificates
    systemd.services.mkcert-setup = {
      description = "Setup mkcert certificates for ${cfg.domain}";
      wantedBy = [ "multi-user.target" ];
      before = [ "caddy.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        # Create certificate directories
        mkdir -p /etc/ssl/certs
        mkdir -p /etc/ssl/private

        # Set proper permissions
        chmod 755 /etc/ssl/certs
        chmod 700 /etc/ssl/private

        # Use the user's home directory from NixOS config
        USER_HOME="${userHome}"
        MKCERT_DIR="$USER_HOME/.local/share/mkcert"

        echo "Looking for certificates in: $MKCERT_DIR"

        # Find and copy mkcert CA certificate
        if [ -d "$MKCERT_DIR" ]; then
          CA_FILE=$(find "$MKCERT_DIR" -name "rootCA.pem" 2>/dev/null | head -1)
          if [ -n "$CA_FILE" ] && [ -f "$CA_FILE" ]; then
            cp "$CA_FILE" /etc/ssl/certs/mkcert-ca.pem
            chmod 644 /etc/ssl/certs/mkcert-ca.pem
            echo "Copied mkcert CA certificate from $CA_FILE"
          else
            echo "Warning: rootCA.pem not found in $MKCERT_DIR"
          fi

          # Find and copy domain certificate
          CERT_FILE=$(find "$MKCERT_DIR" -name "*${cfg.domain}.pem" -not -name "*-key.pem" 2>/dev/null | head -1)
          if [ -n "$CERT_FILE" ] && [ -f "$CERT_FILE" ]; then
            cp "$CERT_FILE" /etc/ssl/certs/${cfg.domain}.pem
            chmod 644 /etc/ssl/certs/${cfg.domain}.pem
            echo "Copied domain certificate from $CERT_FILE"
          else
            echo "Warning: Certificate for ${cfg.domain} not found in $MKCERT_DIR"
            echo "Available certificates:"
            ls -la "$MKCERT_DIR"/*.pem 2>/dev/null || echo "No .pem files found"
          fi

          # Find and copy domain private key
          KEY_FILE=$(find "$MKCERT_DIR" -name "*${cfg.domain}-key.pem" 2>/dev/null | head -1)
          if [ -n "$KEY_FILE" ] && [ -f "$KEY_FILE" ]; then
            cp "$KEY_FILE" /etc/ssl/private/${cfg.domain}-key.pem
            chmod 600 /etc/ssl/private/${cfg.domain}-key.pem
            chown caddy:caddy /etc/ssl/private/${cfg.domain}-key.pem
            echo "Copied domain private key from $KEY_FILE"
          else
            echo "Warning: Private key for ${cfg.domain} not found in $MKCERT_DIR"
            echo "Available key files:"
            ls -la "$MKCERT_DIR"/*-key.pem 2>/dev/null || echo "No key files found"
          fi
        else
          echo "Error: mkcert directory $MKCERT_DIR not found"
        fi
      '';
    };

    assertions = [
      {
        assertion = config.users.users ? ${cfg.user};
        message = "User ${cfg.user} must be defined in the NixOS configuration";
      }
    ];

    # Ensure caddy user and group exist
    users.users.caddy = {
      group = "caddy";
      isSystemUser = true;
    };
    users.groups.caddy = {};
  };
}
