"""Pure-logic regression tests for tools.py: header lookup, base64url body
extraction, and the no-token error path. No network, no real Gmail token.

Loads the plugin the same way Hermes's real loader does
(hermes_cli/plugins_loader.py's _load_directory_module: package semantics via
spec_from_file_location under the hermes_plugins.<slug> namespace) rather than
reimplementing that shape, so an import-path regression here would be a
genuine signal, not a test-harness artifact.

Run with the same interpreter hermes-agent uses (see justfile's
check_python_tests, which resolves it dynamically — it's a nix store path
that changes on every rebuild):
    <hermes-agent-env>/bin/python3 hermes-plugins/gmail/test_tools.py
"""

from __future__ import annotations

import base64
import importlib.util
import json
import os
import sys
import types
from pathlib import Path

PLUGIN_DIR = Path(__file__).resolve().parent

# Running this file directly (`python3 test_tools.py`) auto-prepends its own
# directory to sys.path — which then shadows the real `tools` package
# tools.py itself needs (`from tools.registry import ...`), since our local
# tools.py would resolve first. Drop it; submodule_search_locations below
# handles this plugin's own package loading instead.
if sys.path and Path(sys.path[0]).resolve() == PLUGIN_DIR:
    sys.path.pop(0)


def _load_plugin_tools() -> types.ModuleType:
    ns = types.ModuleType("hermes_plugins")
    ns.__path__ = []
    sys.modules.setdefault("hermes_plugins", ns)
    spec = importlib.util.spec_from_file_location(
        "hermes_plugins.gmail", PLUGIN_DIR / "__init__.py", submodule_search_locations=[str(PLUGIN_DIR)])
    assert spec is not None and spec.loader is not None, f"no module spec for {PLUGIN_DIR / '__init__.py'}"
    module = importlib.util.module_from_spec(spec)
    module.__package__ = "hermes_plugins.gmail"
    module.__path__ = [str(PLUGIN_DIR)]
    sys.modules["hermes_plugins.gmail"] = module
    spec.loader.exec_module(module)
    return sys.modules["hermes_plugins.gmail.tools"]


def main() -> None:
    tools = _load_plugin_tools()

    headers = [{"name": "Subject", "value": "hi"}, {"name": "From", "value": "a@b.com"}]
    assert tools._header(headers, "subject") == "hi"
    assert tools._header(headers, "SUBJECT") == "hi", "header lookup should be case-insensitive"
    assert tools._header(headers, "date") == "", "missing header should return '', not raise"

    text = "hello, world — no padding needed? let's see"
    data = base64.urlsafe_b64encode(text.encode("utf-8")).rstrip(b"=").decode("ascii")
    payload = {"mimeType": "multipart/alternative", "parts": [
        {"mimeType": "text/html", "body": {"data": "aWdub3JlZA"}},  # must be skipped
        {"mimeType": "text/plain", "body": {"data": data}},
    ]}
    got = tools._plain_text_body(payload)
    assert got == text, f"base64url padding or part-selection broke: {got!r} != {text!r}"

    msg = {
        "id": "123", "threadId": "t1", "snippet": "snip",
        "payload": {"headers": [
            {"name": "Subject", "value": "s"}, {"name": "From", "value": "f"}, {"name": "Date", "value": "d"},
        ]},
    }
    assert tools._summarize_message(msg) == {
        "id": "123", "thread_id": "t1", "subject": "s", "from": "f", "date": "d", "snippet": "snip",
    }

    # No GMAIL_TOKEN_PATH: GmailClient() raises before the action is even
    # checked, so this exercises the auth-error path specifically, not
    # action validation (that branch needs a real token to reach).
    os.environ.pop("GMAIL_TOKEN_PATH", None)
    result = json.loads(tools._handle_gmail_messages({"action": "list"}))
    assert "error" in result and "GMAIL_TOKEN_PATH" in result["error"], result

    print("all tests passed")


if __name__ == "__main__":
    main()
