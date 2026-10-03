"""Thin Gmail API helper for Hermes native tools.

Auth is a static token.json from a one-time gmail.readonly InstalledAppFlow,
decrypted by sops to the path in GMAIL_TOKEN_PATH (see
modules/hoss-sops.nix). This plugin never runs the OAuth flow itself — hoss
has no browser; the short-lived access token refreshes automatically off the
stored refresh token, same as any other long-running google-auth client.
"""

from __future__ import annotations

import json
import os
from typing import Any

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]


class GmailError(RuntimeError):
    """Base Gmail tool error."""


class GmailAuthError(GmailError):
    """Raised when GMAIL_TOKEN_PATH is missing or unusable."""


def gmail_configured() -> bool:
    """Cheap check_fn body: token file present and has a refresh token. No network call."""
    token_path = os.environ.get("GMAIL_TOKEN_PATH")
    if not token_path:
        return False
    try:
        with open(token_path, encoding="utf-8") as f:
            return bool(json.load(f).get("refresh_token"))
    except Exception:  # noqa: BLE001 — cheap presence probe, any failure just means "not configured"
        return False


class GmailClient:
    def __init__(self) -> None:
        token_path = os.environ.get("GMAIL_TOKEN_PATH")
        if not token_path:
            raise GmailAuthError("GMAIL_TOKEN_PATH is not set — see modules/hoss-sops.nix")
        try:
            creds = Credentials.from_authorized_user_file(token_path, SCOPES)
        except Exception as exc:
            raise GmailAuthError(f"could not read Gmail token at {token_path}: {exc}") from exc
        if creds.expired and creds.refresh_token:
            creds.refresh(Request())
        self._service = build("gmail", "v1", credentials=creds, cache_discovery=False)

    def list_messages(
        self, *, query: str = "", max_results: int = 10, label_ids: list[str] | None = None,
    ) -> dict[str, Any]:
        return self._service.users().messages().list(
            userId="me", q=query or None, maxResults=max(1, min(max_results, 50)), labelIds=label_ids or None,
        ).execute()

    def get_message(self, message_id: str, *, msg_format: str = "metadata") -> dict[str, Any]:
        return self._service.users().messages().get(userId="me", id=message_id, format=msg_format).execute()
