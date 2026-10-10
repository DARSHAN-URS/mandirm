#!/usr/bin/env python3
"""
Uploads local image assets from consumer_app/assets/images to Supabase Storage bucket 'assets'.

Usage:
    python scripts/upload_assets_to_supabase.py --key YOUR_SUPABASE_SERVICE_ROLE_KEY
Or set environment variable:
    export SUPABASE_SERVICE_ROLE_KEY=YOUR_KEY
    python scripts/upload_assets_to_supabase.py
"""

import os
import sys
import argparse
import mimetypes
from pathlib import Path
import urllib.request
import urllib.error

SUPABASE_URL = "https://ndjvkzrxgmxsdrbyeyim.supabase.co"
BUCKET_NAME = "assets"

def main():
    parser = argparse.ArgumentParser(description="Upload Mandirm assets to Supabase Storage")
    parser.add_argument("--key", default=os.environ.get("SUPABASE_SERVICE_ROLE_KEY"), help="Supabase service_role key")
    parser.add_argument("--assets-dir", default=None, help="Path to assets/images directory")
    args = parser.parse_args()

    service_key = args.key
    if not service_key:
        print("\n[!] Supabase Service Role Key is required for bucket administration & upload.")
        print("    You can find it in: Supabase Dashboard -> Project Settings -> API -> service_role key (secret)")
        service_key = input("Enter your Supabase service_role key: ").strip()

    if not service_key:
        print("Error: No service_role key provided. Exiting.")
        sys.exit(1)

    # Locate assets directory
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent
    assets_dir = Path(args.assets_dir) if args.assets_dir else repo_root / "consumer_app" / "assets" / "images"

    if not assets_dir.exists():
        print(f"Error: Assets directory not found at: {assets_dir}")
        sys.exit(1)

    # 1. Ensure bucket exists and is public
    print(f"\n1. Ensuring public bucket '{BUCKET_NAME}' exists...")
    bucket_url = f"{SUPABASE_URL}/storage/v1/bucket"
    headers = {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json"
    }

    bucket_data = f'{{"id": "{BUCKET_NAME}", "name": "{BUCKET_NAME}", "public": true}}'.encode("utf-8")
    req = urllib.request.Request(bucket_url, data=bucket_data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"   Bucket '{BUCKET_NAME}' created successfully.")
    except urllib.error.HTTPError as e:
        if e.code in (400, 409):
            print(f"   Bucket '{BUCKET_NAME}' already exists or ready.")
        else:
            print(f"   Note: Bucket check returned status {e.code}: {e.read().decode('utf-8', errors='ignore')}")

    # 2. Upload files
    files = [f for f in assets_dir.iterdir() if f.is_file() and not f.name.startswith(".")]
    print(f"\n2. Found {len(files)} files to upload to Supabase CDN bucket '{BUCKET_NAME}/assets/images/'...\n")

    uploaded = 0
    failed = 0

    for i, file_path in enumerate(files, 1):
        filename = file_path.name
        # Keep relative path under 'assets/images/<filename>'
        destination_path = f"assets/images/{filename}"
        mime_type, _ = mimetypes.guess_type(str(file_path))
        if not mime_type:
            mime_type = "image/jpeg" if filename.endswith((".jpg", ".jpeg")) else "image/png"

        upload_url = f"{SUPABASE_URL}/storage/v1/object/{BUCKET_NAME}/{destination_path}"
        upload_headers = {
            "apikey": service_key,
            "Authorization": f"Bearer {service_key}",
            "Content-Type": mime_type,
            "x-upsert": "true"
        }

        try:
            with open(file_path, "rb") as f:
                file_bytes = f.read()

            up_req = urllib.request.Request(upload_url, data=file_bytes, headers=upload_headers, method="POST")
            with urllib.request.urlopen(up_req) as resp:
                if resp.status in (200, 201):
                    uploaded += 1
                    print(f"   [{i}/{len(files)}] OK: {destination_path} ({len(file_bytes)/1024:.1f} KB)")
                else:
                    print(f"   [{i}/{len(files)}] Status {resp.status}: {destination_path}")
        except Exception as e:
            failed += 1
            print(f"   [{i}/{len(files)}] FAILED: {filename} -> {e}")

    print("\n" + "="*50)
    print(f"Upload Complete! Successfully uploaded: {uploaded}/{len(files)}")
    if failed > 0:
        print(f"Failed uploads: {failed}")
    print(f"Public CDN URL prefix: {SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/assets/images/<filename>")
    print("="*50 + "\n")

if __name__ == "__main__":
    main()
