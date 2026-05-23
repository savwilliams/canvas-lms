# Memory Technique: Context Refresh + Last Verified Notes

## Why this fits my Canvas work

I use a lightweight memory workflow with Cursor to reduce stale context when working on the Canvas LMS repository.

The workflow connects to:

- `agents/analyze-repo.md`

Before large prompts or repository analysis, I refresh the repository understanding using the existing analysis workflow and verify that important assumptions are still current.

---

# Procedure

## Before starting a new AI session

1. Review `agents/analyze-repo.md`
2. Re-check the repository state after pulls, merges, or dependency changes
3. Update notes if the repository structure changed
4. Include "last verified" information in prompts when relevant

## Example prompt ritual

- "Read agents/analyze-repo.md before making assumptions about repository structure."
- "If architecture assumptions may be stale after a pull or merge, ask for verification first."

---

# Purge / Refresh / Last Verified

## Refresh triggers

- After `git pull`
- After dependency updates
- After major file structure changes
- Before starting a new implementation session

## Purging policy

I avoid reusing long outdated chat context between sessions. Instead, I summarize the current repository state and re-ground Cursor using the latest repository structure.

## Last verified

Last verified repository structure:
- May 14, 2026

---

# Failure Modes and Mitigations

## Failure mode: stale repository assumptions

Cursor may assume old file paths or outdated architecture details after repository changes.

### Mitigation

I refresh repository understanding using `agents/analyze-repo.md` and verify important assumptions after major updates.

---

# Evidence Excerpt

Cursor prompt:

```text
Read agents/analyze-repo.md and summarize how I could avoid stale repository context across long sessions.
```

Cursor response excerpt:

```text
To avoid stale repo context in long sessions, treat the filesystem as the source of truth: periodically rerun build_index.py (especially after structural changes or when manifest.json’s generated_at no longer matches reality) and use per-directory stamp fields to spot subtrees that likely changed instead of trusting an old tree in chat memory. Prefer small, current artifacts—treesummary.txt or trimmed manifest slices—and use repo_search.py to rediscover paths rather than re-pasting large folders or old code blocks; when continuing work, summarize prior conclusions and cite paths and line ranges (marking unchanged files explicitly). Narrow scope or tighten indexer caps if the manifest grows unwieldy, and use a short run header that records what you loaded and when the index was generated so each pass consciously chooses “reuse” versus “refresh.”
```