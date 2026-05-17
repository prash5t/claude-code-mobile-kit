#!/usr/bin/env python3
"""
play-upload.py — upload an AAB to a Google Play Console release track.

Usage:
    python3 play-upload.py \
        --package com.yourorg.yourapp \
        --aab build/app/outputs/bundle/release/app-release.aab \
        --track internal \
        --release-notes-file /tmp/release-notes.txt

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
    parser.add_argument("--package", required=True, help="Android package name (e.g. com.yourorg.yourapp)")
    parser.add_argument("--aab", required=True, help="Path to the signed AAB")
    parser.add_argument(
        "--track",
        default="internal",
        choices=["internal", "alpha", "beta", "production"],
        help="Play Console release track (default: internal)",
    )
    parser.add_argument(
        "--release-notes-file",
        required=False,
        help="Path to a text file with release notes (under 500 chars)",
    )
    parser.add_argument(
        "--release-name",
        required=False,
        help="Human-readable release name; defaults to the version code",
    )
    args = parser.parse_args()

    key_path = os.environ.get("GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH")
    if not key_path or not Path(key_path).exists():
        sys.stderr.write(
            "ERROR: GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH not set or file does not exist.\n"
            "Set it to the path of your Play Console service-account JSON key.\n"
        )
        return 1

    aab_path = Path(args.aab)
    if not aab_path.exists():
        sys.stderr.write(f"ERROR: AAB not found at {aab_path}\n")
        return 1

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        sys.stderr.write(
            "ERROR: missing dependencies. Install with:\n"
            "    pip install google-api-python-client google-auth\n"
        )
        return 1

    credentials = service_account.Credentials.from_service_account_file(
        key_path,
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )

    service = build("androidpublisher", "v3", credentials=credentials)

    print(f"[play-upload] Creating edit for {args.package}...")
    edit = service.edits().insert(packageName=args.package, body={}).execute()
    edit_id = edit["id"]

    try:
        print(f"[play-upload] Uploading {aab_path.name}...")
        media = MediaFileUpload(str(aab_path), mimetype="application/octet-stream", resumable=True)
        upload = service.edits().bundles().upload(
            packageName=args.package,
            editId=edit_id,
            media_body=media,
        ).execute()
        version_code = upload["versionCode"]
        print(f"[play-upload] Uploaded versionCode {version_code}")

        release_body = {
            "name": args.release_name or str(version_code),
            "status": "completed",
            "versionCodes": [str(version_code)],
        }
        if args.release_notes_file:
            notes = Path(args.release_notes_file).read_text(encoding="utf-8").strip()
            release_body["releaseNotes"] = [{"language": "en-US", "text": notes}]

        print(f"[play-upload] Setting release on track '{args.track}'...")
        service.edits().tracks().update(
            packageName=args.package,
            editId=edit_id,
            track=args.track,
            body={"releases": [release_body]},
        ).execute()

        print("[play-upload] Committing edit...")
        service.edits().commit(packageName=args.package, editId=edit_id).execute()

        console_url = f"https://play.google.com/console/u/0/developers/-/app/{args.package}/tracks/{args.track}"
        print(f"\n✓ Uploaded versionCode {version_code} to '{args.track}' track.")
        print(f"  Console: {console_url}")
        return 0

    except Exception as exc:
        sys.stderr.write(f"ERROR during upload: {exc}\n")
        try:
            service.edits().delete(packageName=args.package, editId=edit_id).execute()
        except Exception:
            pass
        return 1


if __name__ == "__main__":
    sys.exit(main())
