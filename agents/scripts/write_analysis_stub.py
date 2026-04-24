#!/usr/bin/env python3
"""
Writes a structured analysis stub (Markdown) from deterministic inputs.
The LLM fills Analysis sections; this script only creates paths and frontmatter.
"""
from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--manifest", type=Path, default=None, help="Optional manifest.json for metadata")
    args = ap.parse_args()

    meta = {}
    if args.manifest and args.manifest.is_file():
        meta = json.loads(args.manifest.read_text(encoding="utf-8"))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    now = datetime.now(timezone.utc).isoformat()
    lines = [
        "---",
        f"analysis_stub_version: 1",
        f"generated_at_utc: {now}",
        f"repo: {args.repo.resolve()}",
        f"index_manifest: {meta.get('generated_at', 'n/a')}",
        "---",
        "",
        "# Analysis (fill in)",
        "",
        "## Scope",
        "",
        "- ",
        "",
        "## Findings",
        "",
        "1. ",
        "",
        "## Open questions",
        "",
        "- ",
        "",
        "## Files to read next",
        "",
        "- ",
        "",
    ]
    args.out.write_text("\n".join(lines), encoding="utf-8")
    print(str(args.out.resolve()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
