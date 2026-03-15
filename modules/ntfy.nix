{ ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.green.chrash.net";
      listen-http = ":8083";
    };
  };
}
