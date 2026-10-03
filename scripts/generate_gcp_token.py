# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "google-auth-oauthlib",
#   "google-api-python-client",
# ]
# ///
"""One-off OAuth flow for a Gmail refresh token. Run on a machine with a
browser — hermes-agent on hoss is headless. Produces token.json; nothing
else leaves this machine."""
import sys

from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]


def main() -> None:
    client_secret_file = sys.argv[1]

    flow = InstalledAppFlow.from_client_secrets_file(client_secret_file, SCOPES)
    creds = flow.run_local_server(port=0)

    with open("token.json", "w") as f:
        f.write(creds.to_json())
    print("wrote token.json")


if __name__ == "__main__":
    main()
