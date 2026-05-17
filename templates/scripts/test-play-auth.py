#!/usr/bin/env python3
"""
test-play-auth.py — quick verification that your Play Console service-account credentials work.

Usage:
    GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH=/path/to/key.json python3 test-play-auth.py

Output on success:
    ✓ Auth OK. Edit created and discarded successfully. You're good to go.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


def main() -> int:
    key_path = os.environ.get("GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH")
    if not key_path:
        sys.stderr.write("ERROR: GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH not set\n")
        return 1
    if not Path(key_path).exists():
        sys.stderr.write(f"ERROR: key file not found at {key_path}\n")
        return 1

    package = input("Package name to test against (e.g. com.yourorg.yourapp): ").strip()
    if not package:
        sys.stderr.write("ERROR: package name required\n")
        return 1

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
    except ImportError:
        sys.stderr.write("ERROR: pip install google-api-python-client google-auth\n")
        return 1

    credentials = service_account.Credentials.from_service_account_file(
        key_path,
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    service = build("androidpublisher", "v3", credentials=credentials)

    try:
        edit = service.edits().insert(packageName=package, body={}).execute()
        edit_id = edit["id"]
        service.edits().delete(packageName=package, editId=edit_id).execute()
    except Exception as exc:
        sys.stderr.write(f"ERROR during auth test: {exc}\n")
        sys.stderr.write(
            "\nCommon causes:\n"
            "- Service account doesn't have access to this package in Play Console (Setup → API access)\n"
            "- Package name typo\n"
            "- Service account JSON key revoked\n"
        )
        return 1

    print(f"\n✓ Auth OK. Edit created and discarded successfully for {package}. You're good to go.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
