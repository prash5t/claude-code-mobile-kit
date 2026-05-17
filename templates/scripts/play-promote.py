#!/usr/bin/env python3
"""
play-promote.py — promote a release from one Play Console track to another.

Usage:
    python3 play-promote.py \
        --package com.yourorg.yourapp \
        --from internal \
        --to production \
        --rollout 1.0

Requires:
    pip install google-api-python-client google-auth google-auth-httplib2

Environment:
    GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH=/path/to/service-account.json
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", required=True)
    parser.add_argument("--from", dest="from_track", required=True, choices=["internal", "alpha", "beta", "production"])
    parser.add_argument("--to", dest="to_track", required=True, choices=["internal", "alpha", "beta", "production"])
    parser.add_argument("--rollout", type=float, default=1.0, help="0.0-1.0 fraction of users to roll out to")
    args = parser.parse_args()

    if not 0.0 < args.rollout <= 1.0:
        sys.stderr.write("ERROR: --rollout must be between 0.0 (exclusive) and 1.0 (inclusive)\n")
        return 1

    key_path = os.environ.get("GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH")
    if not key_path or not Path(key_path).exists():
        sys.stderr.write("ERROR: GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH not set or file missing\n")
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

    edit = service.edits().insert(packageName=args.package, body={}).execute()
    edit_id = edit["id"]

    try:
        # Read the current release on the source track
        from_state = service.edits().tracks().get(
            packageName=args.package,
            editId=edit_id,
            track=args.from_track,
        ).execute()
        releases = from_state.get("releases", [])
        if not releases:
            sys.stderr.write(f"ERROR: no releases on track '{args.from_track}'\n")
            return 1

        # Take the most recent release that's completed
        completed = [r for r in releases if r.get("status") == "completed"]
        if not completed:
            sys.stderr.write(f"ERROR: no completed releases on '{args.from_track}' (only in-progress / drafts)\n")
            return 1

        release = completed[0]
        version_codes = release.get("versionCodes", [])
        if not version_codes:
            sys.stderr.write("ERROR: source release has no versionCodes\n")
            return 1

        # Build the destination release
        dest_release = {
            "name": release.get("name") or version_codes[0],
            "versionCodes": version_codes,
            "releaseNotes": release.get("releaseNotes", []),
        }
        if args.rollout < 1.0:
            dest_release["status"] = "inProgress"
            dest_release["userFraction"] = args.rollout
        else:
            dest_release["status"] = "completed"

        print(f"[play-promote] Setting release on '{args.to_track}' (versionCodes={version_codes}, rollout={args.rollout})")
        service.edits().tracks().update(
            packageName=args.package,
            editId=edit_id,
            track=args.to_track,
            body={"releases": [dest_release]},
        ).execute()

        service.edits().commit(packageName=args.package, editId=edit_id).execute()

        print(f"\n✓ Promoted versionCodes {version_codes} from '{args.from_track}' to '{args.to_track}' at rollout {args.rollout}")
        return 0

    except Exception as exc:
        sys.stderr.write(f"ERROR: {exc}\n")
        try:
            service.edits().delete(packageName=args.package, editId=edit_id).execute()
        except Exception:
            pass
        return 1


if __name__ == "__main__":
    sys.exit(main())
