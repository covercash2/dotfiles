"""Gmail integration plugin — read-only (gmail.readonly), personal use.

Registers one tool, gmail_messages, gated on a readable GMAIL_TOKEN_PATH
(gmail_configured in client.py). See client.py for how that token gets here.
"""

from __future__ import annotations

from . import tools as _t
from .client import gmail_configured


def register(ctx) -> None:
    ctx.register_tool(
        name="gmail_messages", toolset="gmail", schema=_t.GMAIL_MESSAGES_SCHEMA,
        handler=_t._handle_gmail_messages, check_fn=gmail_configured,
        requires_env=["GMAIL_TOKEN_PATH"], emoji="📧",
    )
