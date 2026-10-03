"""Native Gmail tool for Hermes (registered via plugins/gmail).

Read-only: list/search messages and fetch one message's headers + plain-text
body. Gmail API auth lives in client.py; this module just adapts tool
args/results, mirroring the bundled plugins/spotify/tools.py shape.
"""

from __future__ import annotations

import base64
from typing import Any

from tools.registry import tool_error, tool_result

from .client import GmailClient, GmailError

COMMON_STRING = {"type": "string"}
_INT = {"type": "integer"}
_STR_ARRAY = {"type": "array", "items": COMMON_STRING}


def _schema(name: str, description: str, properties: dict[str, Any], required: tuple[str, ...] = ()) -> dict[str, Any]:
    return {"name": name, "description": description,
            "parameters": {"type": "object", "properties": properties, "required": list(required)}}


def _header(headers: list[dict[str, str]], name: str) -> str:
    name = name.lower()
    return next((h["value"] for h in headers if h.get("name", "").lower() == name), "")


def _plain_text_body(payload: dict[str, Any]) -> str:
    """Depth-first search for the first text/plain part; '' if none."""
    if payload.get("mimeType") == "text/plain":
        data = payload.get("body", {}).get("data", "")
        return base64.urlsafe_b64decode(data + "=" * (-len(data) % 4)).decode("utf-8", "replace") if data else ""
    for part in payload.get("parts", []) or []:
        found = _plain_text_body(part)
        if found:
            return found
    return ""


def _summarize_message(msg: dict[str, Any]) -> dict[str, Any]:
    headers = msg.get("payload", {}).get("headers", [])
    return {
        "id": msg.get("id"),
        "thread_id": msg.get("threadId"),
        "subject": _header(headers, "subject"),
        "from": _header(headers, "from"),
        "date": _header(headers, "date"),
        "snippet": msg.get("snippet", ""),
    }


def _handle_gmail_messages(args: dict, **kw) -> str:
    action = str(args.get("action") or "list").strip().lower()
    try:
        client = GmailClient()
        if action == "list":
            result = client.list_messages(
                query=str(args.get("query") or ""),
                max_results=int(args.get("max_results") or 10),
                label_ids=args.get("label_ids"),
            )
            ids = [m["id"] for m in result.get("messages", [])]
            messages = [_summarize_message(client.get_message(mid)) for mid in ids]
            return tool_result({"messages": messages, "result_size_estimate": result.get("resultSizeEstimate")})
        if action == "get":
            message_id = str(args.get("message_id") or "").strip()
            if not message_id:
                return tool_error("message_id is required for action='get'")
            msg = client.get_message(message_id, msg_format="full")
            summary = _summarize_message(msg)
            summary["body"] = _plain_text_body(msg.get("payload", {})) or msg.get("snippet", "")
            return tool_result(summary)
        return tool_error("action must be one of: list, get")
    except GmailError as exc:
        return tool_error(str(exc))
    except Exception as exc:  # noqa: BLE001 — dispatch boundary: never let an unexpected error crash the agent
        return tool_error(f"Gmail tool failed: {type(exc).__name__}: {exc}")


GMAIL_MESSAGES_SCHEMA = _schema(
    "gmail_messages",
    "Search/list Gmail messages (action='list', Gmail search syntax in `query`) or fetch one "
    "message's headers + plain-text body (action='get', needs `message_id`). Read-only.",
    {
        "action": {"type": "string", "enum": ["list", "get"]},
        "query": {**COMMON_STRING, "description": "Gmail search syntax, e.g. 'from:bob is:unread newer_than:7d'"},
        "max_results": _INT,
        "label_ids": _STR_ARRAY,
        "message_id": COMMON_STRING,
    },
    ("action",),
)
