# Lab 3.2 — Implementation evidence (Feature 1)

**Project:** [@pre-submission feedback](https://github.com/users/savwilliams/projects/1)

---

## Slice 1 — Feature flag, stub API, button (merged)

| Field | Value |
|-------|--------|
| **PR** | https://github.com/savwilliams/canvas-lms/pull/2 (merged) |
| **Branch** | `feature/ai-rubric-feedback-slice-1` |
| **Merge commit** | https://github.com/savwilliams/canvas-lms/commit/019a9bc1bfc270f3ab8279cae8e3c11f5ea8dfcf |
| **Board item** | https://github.com/savwilliams/canvas-lms/issues/1 — Done |

**Scope:** `ai_rubric_feedback` flag, `POST .../ai_rubric_feedback` stub, gated **Get AI Feedback** on A2 student submission footer.

**Plan trace:** `feature-1.md` FR §2.1–2.3 at stub level (flag, text input, placeholder JSON).

---

## Slice 2 — Rubric-aware feedback (merged)

| Field | Value |
|-------|--------|
| **Issue** | https://github.com/savwilliams/canvas-lms/issues/7 |
| **PR** | https://github.com/savwilliams/canvas-lms/pull/7 (merged) |
| **Merge commit** | https://github.com/savwilliams/canvas-lms/commit/a839dac5a3874be71e265561e467a47669ee7cc1 |
| **Branch** | `feature/ai-rubric-feedback-slice-2` |
| **Description** | `AiRubricFeedbackService` heuristics per rubric criterion; structured `criteria` / `weak_areas` / `suggestions`; TextArea paste fix |

### Board workflow (slice 2)

| Project item | Before | After start | After PR | After merge |
|--------------|--------|-------------|----------|-------------|
| [Slice 2: Rubric-aware pre-submission feedback](https://github.com/savwilliams/canvas-lms/issues/7) | Todo | In progress | In review | Done |

**MCP used?** No — project item and PR linked manually (2026-06-02).

### Plan trace (slice 2)

Implements **FR §2.2–2.4** from `feature-1.md`: accept draft text; return structured weak areas and suggestions keyed to rubric criteria; no grade/submission writes. Uses local heuristics (no external LLM). Defers LLM provider, file uploads, instructor tooling.

### Dev / test course

See `agents/tasks/feature-1/pre-submission-test-setup.md` — Writing course, Essay 1, `assignments_2_student` + `ai_rubric_feedback` flags required.

---

## Pre-submission test setup (merged)

| Field | Value |
|-------|--------|
| **PR** | https://github.com/savwilliams/canvas-lms/pull/5 (merged) |
| **Issue** | https://github.com/savwilliams/canvas-lms/issues/4 |

Rubric script + Frankenstein essay dev course runbook (`script/update_frankenstein_rubric.rb`).
