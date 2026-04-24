#!/usr/bin/env python3
"""
Deterministic repository indexer for the analyze-repo agent.
Walks the tree (respecting .gitignore when available), skips heavy dirs,
and writes bounded JSON + a short text summary for fast lookup without
loading the full tree into an LLM context.
"""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import sys
from collections import Counter
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

DEFAULT_SKIP_DIRS = frozenset(
    {
        ".git",
        "node_modules",
        "vendor",
        "tmp",
        "log",
        "coverage",
        "coverage-js",
        "dist",
        "build",
        ".next",
        "__pycache__",
        ".pytest_cache",
        ".turbo",
        "public/dist",
    }
)

KEY_FILE_NAMES = frozenset(
    {
        "README.md",
        "README",
        "AGENTS.md",
        "CLAUDE.md",
        "package.json",
        "yarn.lock",
        "Gemfile",
        "Rakefile",
        "docker-compose.yml",
        "Dockerfile",
        ".rubocop.yml",
        "tsconfig.json",
    }
)


@dataclass
class DirEntry:
    path: str
    file_count: int
    immediate_subdirs: list[str]
    top_extensions: dict[str, int]
    sample_files: list[str]
    stamp: str


def load_gitignore_patterns(repo_root: Path) -> list[str]:
    gi = repo_root / ".gitignore"
    if not gi.is_file():
        return []
    patterns: list[str] = []
    for line in gi.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(line)
    return patterns


def path_matches_any(rel: str, patterns: Iterable[str]) -> bool:
    rel_norm = rel.replace("\\", "/")
    for p in patterns:
        if fnmatch.fnmatch(rel_norm, p) or fnmatch.fnmatch(os.path.basename(rel_norm), p):
            return True
        if p.endswith("/") and fnmatch.fnmatch(rel_norm + "/", p):
            return True
    return False


def safe_relpath(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root)).replace("\\", "/")
    except ValueError:
        return str(path)


def dir_signature(files: list[Path], root: Path, max_bytes: int = 48_000) -> str:
    """Stable hash of file paths + sizes + mtimes under a directory (bounded read)."""
    lines: list[str] = []
    total = 0
    for f in sorted(files, key=lambda p: str(p)):
        rel = safe_relpath(f, root)
        try:
            st = f.stat()
            line = f"{rel}\t{st.st_size}\t{int(st.st_mtime)}"
        except OSError:
            line = f"{rel}\t?\t?"
        lines.append(line)
        total += len(line) + 1
        if total > max_bytes:
            break
    blob = "\n".join(lines).encode("utf-8", errors="replace")
    return hashlib.sha256(blob).hexdigest()[:16]


def build_index(
    repo_root: Path,
    out_dir: Path,
    max_depth: int,
    max_files_per_dir: int,
    max_total_files_listed: int,
) -> None:
    repo_root = repo_root.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    gitignore = load_gitignore_patterns(repo_root)
    # Broad patterns from .gitignore often use leading / — fnmatch is simple; good enough for skipping obvious noise
    skip_name_set = set(DEFAULT_SKIP_DIRS)

    dir_files: dict[str, list[Path]] = {}
    dir_subdirs: dict[str, list[str]] = {}
    key_files: list[str] = []
    extension_counter: Counter[str] = Counter()
    total_seen = 0

    for dirpath, dirnames, filenames in os.walk(repo_root, topdown=True):
        current = Path(dirpath)
        rel_dir = safe_relpath(current, repo_root) or "."

        # prune
        pruned: list[str] = []
        for d in list(dirnames):
            if d in skip_name_set:
                dirnames.remove(d)
                continue
            sub_rel = f"{rel_dir}/{d}".strip("/") if rel_dir != "." else d
            if path_matches_any(sub_rel, gitignore):
                dirnames.remove(d)
                continue
            depth = sub_rel.count("/") + 1
            if depth > max_depth:
                dirnames.remove(d)
                continue
            pruned.append(d)
        dir_subdirs[rel_dir] = sorted(pruned)

        rel_files: list[Path] = []
        for name in filenames:
            fp = current / name
            rel = safe_relpath(fp, repo_root)
            if path_matches_any(rel, gitignore):
                continue
            rel_files.append(fp)
            ext = fp.suffix.lower() or "(noext)"
            extension_counter[ext] += 1
            if name in KEY_FILE_NAMES:
                key_files.append(rel)
            total_seen += 1
            if total_seen > max_total_files_listed:
                break
        dir_files[rel_dir] = rel_files
        if total_seen > max_total_files_listed:
            break

    # Per-directory aggregates (bounded)
    directories: list[DirEntry] = []
    for rel_dir in sorted(dir_files.keys()):
        files = dir_files[rel_dir]
        ext_counts: Counter[str] = Counter()
        for f in files:
            ext_counts[f.suffix.lower() or "(noext)"] += 1
        top_ext = dict(ext_counts.most_common(8))
        sample = [safe_relpath(p, repo_root) for p in sorted(files)[:max_files_per_dir]]
        sig = dir_signature(files, repo_root)
        directories.append(
            DirEntry(
                path=rel_dir,
                file_count=len(files),
                immediate_subdirs=dir_subdirs.get(rel_dir, []),
                top_extensions=top_ext,
                sample_files=sample,
                stamp=sig,
            )
        )

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "repo_root": str(repo_root),
        "params": {
            "max_depth": max_depth,
            "max_files_per_dir": max_files_per_dir,
            "max_total_files_listed": max_total_files_listed,
        },
        "totals": {
            "directories_indexed": len(directories),
            "files_seen_walk": total_seen,
            "top_extensions_global": dict(extension_counter.most_common(20)),
        },
        "key_files": sorted(set(key_files)),
        "directories": [asdict(d) for d in directories],
    }

    manifest_path = out_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    summary_lines = [
        f"Repo: {repo_root}",
        f"Generated (UTC): {manifest['generated_at']}",
        f"Directories (bounded walk): {len(directories)}",
        f"Files seen in walk (cap {max_total_files_listed}): {total_seen}",
        "",
        "Key files (name heuristic):",
    ]
    for k in manifest["key_files"][:50]:
        summary_lines.append(f"  - {k}")
    summary_lines.extend(["", "Top extensions (global):",])
    for ext, c in extension_counter.most_common(15):
        summary_lines.append(f"  {ext or '(noext)'}: {c}")
    summary_lines.extend(["", "First 40 directory rows (path | files | top ext):",])
    for d in directories[:40]:
        top = next(iter(d.top_extensions.keys()), "") if d.top_extensions else ""
        summary_lines.append(f"  {d.path}\t{d.file_count}\t{top}")

    (out_dir / "treesummary.txt").write_text("\n".join(summary_lines) + "\n", encoding="utf-8")

    print(f"Wrote {manifest_path}", file=sys.stderr)
    print(f"Wrote {out_dir / 'treesummary.txt'}", file=sys.stderr)


def main() -> int:
    p = argparse.ArgumentParser(description="Build bounded repo index JSON + summary.")
    p.add_argument("--repo", type=Path, default=Path.cwd(), help="Repository root (default: cwd)")
    p.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output directory (default: <repo>/agents/repo-index/generated)",
    )
    p.add_argument("--max-depth", type=int, default=6, help="Max directory depth from root")
    p.add_argument("--max-per-dir", type=int, default=30, help="Max sample files listed per directory")
    p.add_argument("--max-total", type=int, default=50_000, help="Stop walk after this many files seen")
    args = p.parse_args()

    repo = args.repo.resolve()
    out = args.out or (repo / "agents" / "repo-index" / "generated")
    if not repo.is_dir():
        print(f"Not a directory: {repo}", file=sys.stderr)
        return 2
    build_index(repo, out, args.max_depth, args.max_per_dir, args.max_total)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
