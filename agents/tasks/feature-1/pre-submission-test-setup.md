# Pre-submission feedback — dev test course setup

Local Canvas setup for manually testing **Get AI Feedback** (AI Rubric Feedback slice 1) on a realistic writing assignment.

## Course and accounts

| Item | Value |
|------|--------|
| Course | **Writing** (`course_id=1`) |
| Assignment | **Essay 1: Frankenstein Literary Analysis** (`assignment_id=1`) |
| Teacher | `demo@example.com` (site admin) |
| Test student | `student@example.com` / `CanvasDemo2026!` |
| URL | `/courses/1/assignments/1` |

## Assignment configuration

- **Submission type:** Text entry (`online_text_entry`)
- **Topic (single prompt):** How does Mary Shelley use Victor Frankenstein and the Creature to explore responsibility for scientific creation?
- **Minimum length:** 500 words (body; Works Cited excluded)
- **Feature flags (both required):**
  - `assignments_2_student` — loads the A2 submission page where the button lives
  - `ai_rubric_feedback` — enables the API and **Get AI Feedback** button

## Rubric

**Title:** Frankenstein Essay Rubric (100 pts)

One quantifiable metric per criterion:

| Criterion | Metric |
|-----------|--------|
| Word count (minimum 500) | Body word count |
| Thesis in introduction | Debatable thesis in intro |
| Direct quotations from Frankenstein | Count of direct quotes |
| Body paragraph count | Number of body paragraphs |
| Analysis sentences | % of body sentences that analyze vs. summarize |
| MLA in-text citations | Count of in-text citations |

## Enable feature flags (one-time per course)

```bash
docker compose exec -T web bundle exec rails runner "
  c = Course.find(1)
  c.enable_feature!(:assignments_2_student)
  c.enable_feature!(:ai_rubric_feedback)
  puts \"a2_enabled=#{Assignment.find(1).a2_enabled?}\"
"
```

Without **Assignment Enhancements - Student** (`assignments_2_student`), you will see the **classic** assignment page and **no** Get AI Feedback button.

## Apply or refresh rubric + assignment text

From repo root (Docker web container running):

```bash
docker compose exec -T web bundle exec rails runner script/update_frankenstein_rubric.rb
```

## IDE / TypeScript notes

Root `tsconfig.json` references `vitest/globals` and `jqueryui` types from `node_modules`. If your editor shows errors under `ui/`, install JS deps once on the host (or use the web container’s `node_modules`):

```bash
yarn install   # from repo root; can take several minutes
```

## Blank assignment page?

The A2 page is a React app. If the content area is **blank**:

1. **Use one URL only** — match `config/domain.yml` `development.domain` (e.g. `localhost` for SSH tunnel, or your EC2 IP if you browse by IP). Do not switch between `localhost` and the public IP in the same browser.
2. **Rebuild assets** after pulling feature code:
   ```bash
   ./script/fix_dev_assignment_page.sh
   ```
3. Hard refresh (Ctrl+Shift+R) or a private window after changing domain or assets.

## Verify AI feedback button (student view)

1. Log in as `student@example.com` or use **Student View** as teacher.
2. Open the assignment URL above.
3. Confirm **Get AI Feedback** appears when the rubric is attached and the flag is on.
4. Paste draft text and submit; expect stub JSON feedback (no LLM in slice 1).

## Related implementation (already on `master`)

- PR #2 — feature flag, stub API, UI button
- PR #3 — QA agent spec, RSpec + JS tests
