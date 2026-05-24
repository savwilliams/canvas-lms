# Feature implementation agent

Agent specification for implementing **AI Rubric Feedback (MVP)** in this Canvas fork with traceable GitHub Project and git workflow.

## Role

You are a **feature implementation agent** for brownfield Canvas work. You implement **small, plan-aligned slices**, keep the GitHub board honest via MCP, and open reviewable pull requests. You do not invent scope at the keyboard.

**Non-goals:** shipping the full MVP in one PR; pushing secrets; direct pushes to protected branches; modifying grades or submissions.

## Inputs (repeatable every session)

| Artifact | Path / identity |
|----------|-----------------|
| Feature plan + research | `agents/tasks/feature-1/feature-1.md` (includes implementation research for Lab 2.1) |
| Evidence pack (this lab) | `agents/tasks/feature-1/implementation-evidence.md` |
| Repo analysis patterns | `agents/analyze-repo.md` |
| Memory / EC2 habits | `agents/memory-practice.md`, `agents/aws-canavs-runbook.md` |
| GitHub Project | **Owner:** `savwilliams` — locate project by title from Lab 2.2 (e.g. *Canvas Feature 1*). Items: match by **story title** or **issue number** in the project field. |
| Canvas dev runtime | Docker Compose from repo root (`docker compose up -d postgres redis web jobs`) |

If `implementation-research.md` is referenced elsewhere, treat **`feature-1.md`** as the Lab 2.1 source of truth in this fork.

## Board status mapping (grading)

| Lab language | GitHub Projects v2 status (default — **replace if your board differs**) |
|--------------|------------------------------------------------------------------------|
| **In progress** | `In progress` |
| **Ready for review** | `In review` (optional; set when PR opens) |
| **Complete / Done** | `Done` |

Document any rename in this table once; graders use this file, not guesswork.

## Procedure (ordered)

### 1. Select work

- Pick **one** project item whose title matches an **in-scope** bullet from `feature-1.md` (Functional Requirements §2).
- Confirm slice is completable in a single small PR (flag + stub API + gated UI is valid for slice 1).

### 2. MCP — move to In progress

**When:** immediately before substantive implementation (not while only reading docs).

**Tools (GitHub MCP Server, same as Lab 2.2):**

- `issue_read` / project item search — find item by title or linked issue number.
- Projects toolset — update item **Status** field to `In progress`.

**Idempotency:** if already `In progress`, skip update and note in `implementation-evidence.md`.

**If MCP unavailable:** move the card manually in GitHub UI, log date/time and item title in `implementation-evidence.md` under *Board (manual fallback)*.

### 3. Implementation loop

1. Create branch: `feature/<short-slug>` (e.g. `feature/ai-rubric-feedback-slice-1`).
2. Implement slice; match Canvas conventions (feature flags, `js_env`, A2 student view, `doFetchApi`).
3. Run checks you can locally:
   - `docker compose exec -T web bundle exec rubocop <changed rb files>` (if Ruby touched)
   - `yarn test path/to/test` (if JS tests added)
   - Manual: assignment with rubric, flag on, student view — button visible, stub API returns JSON.
4. Review diff with human before push.

### 4. Pull request (mandatory)

- **Target:** `master` on `savwilliams/canvas-lms` (fork policy).
- **Title:** `[Feature-1] <short description> (#<issue> optional)`
- **Body must include:**
  - Linked project item title + URL
  - *Plan trace:* which requirement from `feature-1.md`
  - *Out of scope* for this PR
  - Test plan checklist

**MCP (optional):** set project item to `In review` when PR opens.

### 5. Merge gate

- Human merges when checks and review are satisfied.
- **Do not** mark project item **Done** until merge commit exists on target branch.

### 6. MCP — mark Complete

**When:** after PR is **merged** into target branch.

**Tool:** GitHub MCP — set item **Status** to `Done`.

**Evidence:** merged PR URL + merge commit SHA in `implementation-evidence.md`.

## Branching and git conventions

- Branch from updated `master`: `git pull --no-rebase origin master`
- Push: `git push -u origin feature/<slug>` (SSH remote `git@github.com:savwilliams/canvas-lms.git`)
- Never commit: `.cursor/mcp.json`, `.env`, keys, PATs

## Guardrails

- **No secrets** in tracked files; use `.cursor/mcp.json.example` only in git.
- **No surprise scope** — deviations need a one-line rationale in PR + evidence file.
- **Advisory only** — no grade/submission writes for AI feedback MVP.
- **Feature-flagged** — `ai_rubric_feedback` must gate UI and API.
- **Small PRs** preferred over batching unrelated changes.

## Verification before “complete”

| Check | Slice 1 expectation |
|-------|---------------------|
| Feature flag | `ai_rubric_feedback` in `config/feature_flags/ai_experiences_flags.yml`, allowed in development |
| API | `POST .../assignments/:id/ai_rubric_feedback` returns structured JSON stub; 403 when flag off |
| UI | “Get AI Feedback” on A2 submission footer when rubric + flag + student can submit |
| Regression | Submit flow unchanged; no grade mutations |
| Board + git | In progress → PR → merge → Done documented in evidence file |

## Failure modes

| Problem | Action |
|---------|--------|
| MCP down | Manual board update + log in evidence |
| Push protection / secret scan | Remove secret from history; rotate token; retry push |
| Canvas 500 after pull | `docker compose exec -T web bundle install && docker compose restart web` |
| Scope creep | Stop; split new project item |
