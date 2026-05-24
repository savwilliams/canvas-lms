# Lab 3.2 — Implementation evidence (Feature 1)

## PR

| Field | Value |
|-------|--------|
| **URL** | _TODO after open — e.g. `https://github.com/savwilliams/canvas-lms/pull/___`_ |
| **Branch** | `feature/ai-rubric-feedback-slice-1` |
| **Description** | Slice 1: `ai_rubric_feedback` feature flag, stub `POST .../ai_rubric_feedback` API, gated **Get AI Feedback** button on A2 student submission footer. No AI provider call; no grade/submission changes. |

## Board workflow

**Project:** _TODO — paste GitHub Project URL from Lab 2.2_

| Project item (title) | Before | After start | After PR | After merge |
|----------------------|--------|-------------|----------|-------------|
| _e.g. “Slice 1: feature flag + stub API + button”_ | _Todo_ | _In progress_ | _In review (optional)_ | _Done_ |

**MCP used?** _Yes / No — if No, note manual move date/time below._

**Manual fallback log:** _optional_

## Merge evidence

| Field | Value |
|-------|--------|
| **Merged PR** | _TODO — link to merged PR_ |
| **Merge commit** | _TODO — SHA on `master`_ |
| **Blocker** | _None / instructor must merge — explain_ |

## Plan trace

This slice implements **Functional Requirements §2 (in scope)** items 1–3 at stub level from `agents/tasks/feature-1/feature-1.md`: show **Get AI Feedback** when the assignment has a rubric and the course flag is on; accept draft text via API; return structured placeholder feedback without modifying grades or submissions. It follows the project story for MVP foundation (flag + API + UI entry point) and defers LLM integration, file uploads, and instructor tooling per **Out of Scope**. Deviations: none beyond intentional stub response text.
