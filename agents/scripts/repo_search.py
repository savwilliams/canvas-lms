#!/usr/bin/env python3
"""
Thin deterministic search wrapper using ripgrep when available, else Python fallback.
Emits JSON lines for machine consumption; no LLM involvement.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def run_rg(repo: Path, pattern: str, glob: str | None, max_count: int) -> list[dict]:
    rg = shutil.which("rg")
    if not rg:
        return []
    cmd = [
        rg,
        "--json",
        "--max-count",
        str(max_count),
        "--no-heading",
        "--hidden",
        "--glob",
        "!.git/*",
    ]
    if glob:
        cmd.extend(["--glob", glob])
    cmd.extend([pattern, str(repo)])
    proc = subprocess.run(cmd, capture_output=True, text=True, cwd=repo)
    matches: list[dict] = []
    for line in proc.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if obj.get("type") == "match":
            d = obj.get("data", {})
            path = d.get("path", {}).get("text")
            lines = d.get("lines", {}).get("text", "").rstrip("\n")
            ln = d.get("line_number")
            if path:
                matches.append({"path": path, "line": ln, "text": lines})
    return matches


def run_python_grep(repo: Path, pattern: str, max_count: int) -> list[dict]:
    import re

    compiled = re.compile(pattern)
    matches: list[dict] = []
    for p in repo.rglob("*"):
        if p.is_dir():
            continue
        rel = str(p.relative_to(repo))
        if ".git" in rel.split("/") or "node_modules" in rel.split("/"):
            continue
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except (OSError, UnicodeError):
            continue
        for i, line in enumerate(text.splitlines(), start=1):
            if compiled.search(line):
                matches.append({"path": rel.replace("\\", "/"), "line": i, "text": line[:500]})
                if len(matches) >= max_count:
                    return matches
    return matches


def main() -> int:
    ap = argparse.ArgumentParser(description="Deterministic repo search -> JSON on stdout.")
    ap.add_argument("--repo", type=Path, default=Path.cwd())
    ap.add_argument("pattern", help="Regex pattern (rg syntax if rg present)")
    ap.add_argument("--glob", dest="glob_pat", default=None, help="Optional glob filter, e.g. '*.rb'")
    ap.add_argument("--max", type=int, default=200, help="Max matches")
    args = ap.parse_args()
    repo = args.repo.resolve()
    if not repo.is_dir():
        print(json.dumps({"error": f"not a directory: {repo}"}), file=sys.stderr)
        return 2

    if shutil.which("rg"):
        matches = run_rg(repo, args.pattern, args.glob_pat, args.max)
    else:
        matches = run_python_grep(repo, args.pattern, args.max)

    print(json.dumps({"pattern": args.pattern, "matches": matches}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
