# Lab 4.1 — QA evidence (Feature 1)

**Project:** [@pre-submission feedback](https://github.com/users/savwilliams/projects/1)

---

## Slice 1 — QA (merged)

| Field | Value |
|-------|--------|
| **Project item** | Test (`canvas-lms #1`) — https://github.com/savwilliams/canvas-lms/issues/1 |
| **Implementation PR** | https://github.com/savwilliams/canvas-lms/pull/2 (merged) |
| **QA PR** | https://github.com/savwilliams/canvas-lms/pull/3 (merged) |
| **QA merge commit** | https://github.com/savwilliams/canvas-lms/commit/8851a9684401cfcd8960e028309a19285b5e898b |

### Tests (slice 1)

| Path | What it covers |
|------|----------------|
| `spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb` | Flag off → 403; flag on → 200; blank `draft_text` → 422 |
| `ui/features/assignments_show_student/react/helpers/__tests__/RubricHelpers.test.ts` | `shouldRenderAiRubricFeedback` gating |

### Commands (slice 1) — **PASS**

```bash
docker compose exec -T web bundle exec rspec spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb
docker compose exec -T web yarn test ui/features/assignments_show_student/react/helpers/__tests__/RubricHelpers.test.ts
```

---

## Slice 2 — QA (merged)

| Field | Value |
|-------|--------|
| **Issue** | https://github.com/savwilliams/canvas-lms/issues/7 |
| **Implementation PR** | https://github.com/savwilliams/canvas-lms/pull/7 (merged) |
| **Merge commit** | https://github.com/savwilliams/canvas-lms/commit/a839dac5a3874be71e265561e467a47669ee7cc1 |
| **Branch** | `feature/ai-rubric-feedback-slice-2` |

### Tests added or updated (slice 2)

| Path | What it covers |
|------|----------------|
| `app/services/ai_rubric_feedback_service.rb` | Per-criterion heuristics (word count, thesis, quotes, paragraphs, analysis, MLA) |
| `spec/services/ai_rubric_feedback_service_spec.rb` | Short vs long draft; draft too long |
| `spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb` | Rubric-aligned JSON; draft too long → 422 |
| `AiRubricFeedbackButton.tsx` | TextArea `onChange` fix (InstUI event-only API); criteria list UI |

### Commands and outcomes (slice 2)

| Command | Outcome |
|---------|---------|
| `docker compose exec -T web bundle exec rspec spec/services/ai_rubric_feedback_service_spec.rb spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb` | **PASS** — 7 examples, 0 failures |
| Manual: student → Essay 1 → **Get AI Feedback** → paste draft → **Request feedback** | **PASS** — rubric feedback displayed (2026-06-02) |

### Exception (slice 2)

None. Behavior-changing code; automated + manual tests recorded.

### Plan trace (slice 2)

QA validates **FR §2.2–2.4**: structured feedback with `weak_areas`, `suggestions`, and per-criterion `criteria` from rubric heuristics; advisory only; flag still required.
