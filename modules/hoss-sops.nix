{ ... }:
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.ca_key = {
      sopsFile = ../secrets/hoss.yaml;
      mode = "0400";
    };
  };
}
