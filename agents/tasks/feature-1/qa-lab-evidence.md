# Lab 4.1 — QA evidence (Feature 1)

## Work item

| Field | Value |
|-------|--------|
| **Project item** | Test (`canvas-lms #1`) — https://github.com/savwilliams/canvas-lms/issues/1 |
| **Implementation PR** | https://github.com/savwilliams/canvas-lms/pull/2 (merged) |
| **Merge commit** | https://github.com/savwilliams/canvas-lms/commit/019a9bc1bfc270f3ab8279cae8e3c11f5ea8dfcf |
| **QA branch** | `feature/lab41-qa-ai-rubric-feedback-tests` |
| **QA commit** | https://github.com/savwilliams/canvas-lms/commit/5d321b5cfbdd60cfc7cece13e4185fd8b82c298e |
| **QA PR** | Open from compare: https://github.com/savwilliams/canvas-lms/compare/master...feature/lab41-qa-ai-rubric-feedback-tests?expand=1 |

## Tests added or updated

| Path | What it covers |
|------|----------------|
| `spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb` | `POST ai_rubric_feedback`: flag off → 403; flag on → 200 stub JSON; blank `draft_text` → 422 |
| `ui/features/assignments_show_student/react/helpers/__tests__/RubricHelpers.test.ts` | `shouldRenderAiRubricFeedback`: flag on/off, no rubric |

## Commands and outcomes

Run on EC2 inside Docker (`docker compose up -d postgres redis web`):

| Command | Outcome |
|---------|---------|
| `docker compose exec -T web bundle exec rspec spec/controllers/assignments_controller_ai_rubric_feedback_spec.rb` | **PASS** — 3 examples, 0 failures |
| `docker compose exec -T web yarn test ui/features/assignments_show_student/react/helpers/__tests__/RubricHelpers.test.ts` | **PASS** — 13 tests, 0 failures |

## Exception (no-test cases)

None for this item. Implementation changed **application behavior** (controller + UI gating); automated tests were required and added.

## QA agent spec

Procedure and commands documented in `agents/quality-assurance.md`. Handoff: implementation agent delivers PR → QA agent adds/updates tests → green runs recorded here → item may remain **Done** on board after merge.

## Plan trace

QA validates **Functional Requirements §2** for slice 1 from `agents/tasks/feature-1/feature-1.md`: feature-flag gating, API acceptance of draft text, and UI visibility rules—without asserting external AI content. Matches Lab 3.2 implementation scope (stub only).
